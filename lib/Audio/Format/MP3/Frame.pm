use v6;

class Audio::Format::MP3::Frame {
    use Util::Bitfield;

    enum Mode <Stereo JointStereo DualChannel Mono>;

    my @bitrate =       [
                            [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0],
                            [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 0 ],
                            [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0 ],
                        ],
                        [
                            [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0],
                            [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
                            [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
                        ],
                        [
                            [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0],
                            [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
                            [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
                        ];
    my @samplerate =    [ 44100, 48000, 32000, 0 ],
                        [ 22050, 24000, 16000 ],
                        [ 11025, 8000, 8000, 0 ];

    sub bytes-to-int(Blob $buf where  *.elems == 4 ) returns Int {
	    ($buf[0] +< 24) +|
        ($buf[1] +< 16) +|
        ($buf[2] +< 8) +|
        ($buf[3]);
    }

    sub calculate-framesize(Int $samplerate, Int $samples, Int $bitrate, Int $padding) returns Int {
        $samplerate ?? Int((($samples * $bitrate * 1000)/$samplerate)/8 + $padding) !! 0;
    }

    class Header {
        has Int $.syncword;
        has Int $.layer;
        has Int $.version;
        has Bool $.error-protection;
        has Int $.bitrate-index;
        has Int $.samplerate-index;
        has Int $.padding;
        has Int $.extension;
        has Mode $.mode;
        has Int $.mode-ext;
        has Bool $.copyright;
        has Bool $.original;
        has Int $.emphasis;
        has Bool $.stereo;
        has Int $.bitrate;
        has Int $.samplerate;
        has Int $.samples;
        has Int $.framesize;

        multi method new(Blob $buf where *.elems == 4) {
            my Int $head = bytes-to-int($buf);
            samewith($head);
        }

        multi method new(Int $head) {
            my %a;
            %a<syncword>            = extract-bits($head,11);
            %a<version>             = (2,0,2,1)[extract-bits($head, 2, 11)];
            %a<layer>               = (0, 3, 2, 1)[extract-bits($head, 2, 13)];
            %a<error-protection>    = Bool(!extract-bits($head, 1, 15));
            %a<bitrate-index>       = extract-bits($head, 4, 16);
            %a<samplerate-index>    = extract-bits($head, 2, 20);
            %a<padding>             = extract-bits($head, 1, 22);
            %a<extension>           = extract-bits($head, 1, 23);
            %a<mode>                = Mode(extract-bits($head, 2, 24));
            %a<mode-ext>            = extract-bits($head, 2, 26);
            %a<copyright>           = Bool(extract-bits($head, 1, 28));
            %a<original>            = Bool(extract-bits($head, 1, 29));
            %a<emphasis>            = extract-bits($head, 2, 30);
            %a<bitrate>             = @bitrate[%a<version> - 1][%a<layer> - 1][%a<bitrate-index>];
            %a<samplerate>          = @samplerate[%a<version> - 1][%a<samplerate-index>];
            %a<samples>             = %a<version> ?? 576 !! 1152;
            %a<framesize>           = calculate-framesize(%a<samplerate>, %a<samples>, %a<bitrate>, %a<padding>);
            %a<stereo>              = %a<mode> ~~ Stereo | JointStereo | DualChannel;
            samewith(|%a);
        }

        method is-frame() returns Bool {
            $.syncword == 0b11111111111 && $.bitrate && $.samplerate;
        }
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
