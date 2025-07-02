# ENS Rennes template for presentations

The unofficial ENS Rennes [typst](https://typst.app/home/) template for presentations, based on [touying](https://touying-typ.github.io/).
This template follows the guidelines described in the ENS Rennes graphic charter.

## Import

To import the latest version of the template:
```typst
#import "@preview/ens-rennes-touying-theme/0.1.0" : *
```

## Configurations

The main function exported by the theme is `ens-rennes`.

```typst
#show: ens-theme.with(
  aspect-ratio: "4-3",
  config-info(
    title: [ENS Rennes presentation theme],
    subtitle: [You can also add a subtitle],
    mini-title: [ENS Rennes presentation],
    authors: [Janet Doe],
    date: datetime.today(),
  ),
  department: "info",
  display-dpt: false,
  named-index: true
)
```

It has the following arguments:
- `aspect-ratio`: the aspect-ratio of each slide; 16-9 by default;
- `department`: you can specify your department as a string (info, mktro, dem, 2sep, maths, spen);
- `display-dpt`: set to true if you want the theme to align with the graphic charter of the department rather than the school's; false by default;
- `named-index`: if true, the subtitles will appear atop the page as strings, otherwise they will simply appear as bullets; true by default.

You can provide additional information in the config-info dictionary:
- `title`: the title of the presentation;
- `subtitle`: the subtitle of the presentation;
- `mini-title`: a shortened version of the title, displayed in the footer. If undefined, the title is displayed in the footer.
- `authors`: the author(s) as content;
- `mini-authors`: a shortened version of the authors, displayed in the footer. If undefined, the authors are displayed in the footer.
- `date`: the date you want to appear in the title page.

## Personalization

### Add content in the title

The `title-slide` function has an optional argument `additional-content`, if you want to display some other content in the title page, which will appear below the title and other informations.

### Blocks

The template provides two functions for Beamer-like blocks:
- `new-block(kind:content, color:color)`: for a theorem-like block, the title will always be of the form "kind (the title of this particular box)", some are provided in the example file (`theorem`, `proposition`, `lemma`, `definition`, `example` and `remark`).
- `tblock(color:color, title: content, body)`: for a more personalizable block.
