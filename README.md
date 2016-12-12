# Audio::Format::MP3::Frame

This provides a mechanism for decoding MP3 Frame headers

## Synopsis

```perl6
use Audio::Format::MP3::Frame;

sub MAIN(Str $file) {
    my $handle = $file.IO.open(:bin);

    my $mp3;
    while my $buf = $handle.read(4) {
        $mp3 = Audio::Format::MP3::Frame::Header.new($buf);
        if $mp3.is-frame {
            last;
        }
    }

    say $mp3;

}
```

## Description

This allows you to find the details from the frame headers of an MP3 stream.

An MP3 frame header is a four byte block of data the describes the following
frame of MP3 data, this contains for instance the size of the whole frame,
the bitrate of the encoded data and the encoder version.

You might need to use this information for accurate streaming of MP3 data that
has been encoded by another source or segmenting a file or so forth.


