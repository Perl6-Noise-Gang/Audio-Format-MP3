use v6;

class Audio::Format::MP3::Frame {

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
    sub shift-and(Int $who, Int $many, Int $what ) returns Int {
	    ($who +> $many) +& $what;
    }

    sub make-mask(Int $bits, Int $start = 0, Int $word-size = 32) {
	    (((1 +< $bits) - 1) +< ($word-size - ($bits + $start)));
    }

    sub extract-bits(Int $value, Int $bits, Int $start = 0, Int $word-size = 32) {
	    ($value +& make-mask($bits, $start, $word-size)) +> ( $word-size - ( $bits + $start));
    }

    class Header {
        has Int $.syncword;
        has Int $.layer;
        has Int $.version;
        has Int $.error-protection;
        has Int $.bitrate-index;
        has Int $.samplerate-index;
        has Int $.padding;
        has Int $.extension;
        has Int $.mode;
        has Int $.mode-ext;
        has Int $.copyright;
        has Int $.original;
        has Int $.emphasis;
        has Int $.stereo;
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
            say $head;
            %a<syncword>            = extract-bits($head,11);
            %a<version>             = (2,0,2,1)[extract-bits($head, 2, 11)];
            %a<layer>               = (0, 3, 2, 1)[extract-bits($head, 2, 13)];
            %a<error-protection>    = extract-bits($head, 1, 15);
            %a<bitrate-index>       = extract-bits($head, 4, 16);
            %a<samplerate-index>    = extract-bits($head, 2, 20);
            %a<padding>             = extract-bits($head, 1, 22);
            %a<extension>           = extract-bits($head, 1, 23);
            %a<mode>                = extract-bits($head, 2, 24);
            %a<mode-ext>            = extract-bits($head, 2, 26);
            %a<copyright>           = extract-bits($head, 1, 28);
            %a<original>            = extract-bits($head, 1, 29);
            %a<emphasis>            = extract-bits($head, 2, 30);
            %a<bitrate>             = @bitrate[%a<version> - 1][%a<layer> - 1][%a<bitrate-index>];
            %a<samplerate>          = @samplerate[%a<version> - 1][%a<samplerate-index>];
            samewith(|%a);
        }
   }
}
# vim: expandtab shiftwidth=4 ft=perl6
