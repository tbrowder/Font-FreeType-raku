#| iterator for font typeface glyphs
class Font::FreeType::Glyph {

    use Font::FreeType::_Glyph;
    also is Font::FreeType::_Glyph;

    use NativeCall;
    use Font::FreeType::GlyphImage;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;
    use Font::FreeType::Error;

    use Font::FreeType::BitMap;
    use Font::FreeType::Outline;

    constant Dot6 = Font::FreeType::Raw::Defs::Dot6;

    has FT_GlyphSlot $!raw handles <metrics>;
    submethod TWEAK(FT_GlyphSlot:D :$!raw!) { }
    method left-bearing returns Rat:D { $.metrics.hori-bearing-x / Dot6; }
    method right-bearing returns Rat:D {
        (.hori-advance - .hori-bearing-x - .width) / Dot6
            with $.metrics
    }
    method horizontal-advance returns Rat:D {
        $.metrics.hori-advance / Dot6;
    }
    method vertical-advance returns Rat:D {
        $.metrics.vert-advance / Dot6;
    }
    method width returns Rat:D { $.metrics.width / Dot6 }
    method height returns Rat:D { $.metrics.height / Dot6 }
    method format returns UInt:D { FT_GLYPH_FORMAT($!raw.format) }

    method is-outline {
        $.format == FT_GLYPH_FORMAT_OUTLINE;
    }

    method glyph-image handles<bitmap outline decompose> returns Font::FreeType::GlyphImage:D {
        my $top = $!raw.bitmap-top;
        my $left = $!raw.bitmap-left;
        Font::FreeType::GlyphImage.new: :$.face, :glyph($!raw), :$left, :$top, :$.char-code, :$.index, :$.stat;
    }

}

=begin pod

=head2 Synopsis

    use Font::FreeType;
    use Font::FreeType::Glyph;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('t/fonts/Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    # Do some stuff with glyphs
    $face.for-glyphs: 'ABC', -> Font::FreeType::Glyph $g {
        say "glyph {$g.name} has size {$g.width} X {$g.height}";
        # dump the glyph's bitmap to a binary PGM file
        my $g-image = $g.glyph-image;
        ($g.name() ~ '.pgm').IO.open(:w, :bin).write: $g-image.bitmap.pgm;
    }


=head2 Description

This is an iterator class that represents individual glyphs loaded from a font.

See L<Font::FreeType::Face> for how to obtain glyph objects, in particular the `for-glyph-slots` method.

For a detailed description of the meaning of glyph metrics, and
the structure of vectorial outlines,
see [http://freetype.sourceforge.net/freetype2/docs/glyphs/](http://freetype.sourceforge.net/freetype2/docs/glyphs/)

=head2 Methods

Unless otherwise stated, all methods will die if there is an error,
and the metrics are scaled to the size of the font face.

=head3 char-code()

The character code (in Unicode) of the glyph.  Could potentially
return codes in other character sets if the font doesn't have a Unicode
character mapping, but most modern fonts do.

=head3 index()

The index number of the glyph in the font face.

=head3 is-outline()

True if the glyph has a vector outline, in which case it is safe to
call `decompose()`.  Otherwise, the glyph only has a bitmap
image.

=head3 height()

The height of the glyph.

=head3 horizontal-advance()

The distance from the origin of this glyph to the place where the next
glyph's origin should be.  Only applies to horizontal layouts.  Always
positive, so for right-to-left text (such as Hebrew) it should be
subtracted from the current glyph's position.

=head3 glyph-image()

Return a [Font::FreeType::GlyphImage](GlyphImage.pm) object for the glyph.
This can then be used to obtain bitmaps and outlines.

=head3 left-bearing()

The left side bearing, which is the distance from the origin to
the left of the glyph image.  Usually positive for horizontal layouts
and negative for vertical ones.

=head3 name()

The name of the glyph, if the font format supports glyph names,
otherwise _undef_.

=head3 right-bearing()

The distance from the right edge of the glyph image to the place where
the origin of the next character should be (i.e., the end of the
advance width).  Only applies to horizontal layouts.  Usually positive.

=head3 vertical-advance()

The distance from the origin of the current glyph to the place where
the next glyph's origin should be, moving down the page.  Only applies
to vertical layouts.  Always positive.

=head3 width()

The width of the glyph.  This is the distance from the left
side to the right side, not the amount you should move along before
placing the next glyph when typesetting.  For that, see
the `horizontal_advance()` method.

=head3 Str()

The Unicode character represented by the glyph.

=head2 See Also

=item L<Font::FreeType>
=item L<Font::FreeType::Face>
=item L<Font::FreeType::GlyphImage>

=head2 Copyright

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com>
Copyright 2017.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
