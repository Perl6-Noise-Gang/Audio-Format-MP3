#!perl6

use v6;

use Test;
use Audio::Format::MP3::Frame;
use Audio::Encode::LameMP3;

my @frames = 0 xx 4192;

# I've omitted some combinations as I'm not sure that lame encodes them right
my @bitrates =       [
                            [ 32, 64, 96, 128, 160, 192, 224, 256, 320 ],
                            [ 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320 ],
                            [ 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320 ],
                     ],
                     [
                            [ 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256],
                            [ 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160 ],
                            [ 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160 ],
                     ],
                     [
                            [ 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256],
                            [ 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
                            [ 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
                     ];
my @samplerates =    [ 44100, 48000 ],
                     [ 16000 ],
                     [];

for ^3 -> $version {
    for @samplerates[$version].list -> $samplerate {
        for ^3 -> $layer {
            next if $version > $layer;
            for @bitrates[$version][$layer].list -> $bitrate {
                my $encoder = Audio::Encode::LameMP3.new(bitrate => $bitrate, in-samplerate => $samplerate);
                my $buf = $encoder.encode-short(@frames);
                # some of the resulting combos won't work so just cheat;
                next unless $buf.elems;
                my $head = $buf.subbuf(0,4);
                my $header;
                lives-ok { $header = Audio::Format::MP3::Frame::Header.new($head) }, "get frame version { $version + 1 } Layer { $layer + 1}";
                is $header.bitrate, $bitrate, "bitrate $bitrate ok";
                is $header.samplerate, $samplerate, "samplerate $samplerate ok";
            }
        }
    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
