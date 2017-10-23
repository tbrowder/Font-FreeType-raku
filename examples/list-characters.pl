use Font::FreeType;
use Font::FreeType::Glyph;

sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    $face.foreach-char:
    -> Font::FreeType::Glyph $_ {
        my $char = .char-code.chr;
        my $is-printable = $char ~~ /<print>/;
            say (.char-code, .name, $is-printable ?? $char !! Mu)\
                .map({ .defined ?? ($_) !! '' })\
                .join: "\t";
        }
        
}