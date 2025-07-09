#import "@preview/touying:0.6.1": *
#import "custom-blocks.typ": *

#let alt-cell = block.with(
  width: 100%,
  height: 2.5em,
  above: 0pt,
  below: 0pt,
  breakable: false,
)

#let list-font = ("Univers", "New Computer Modern Sans", "CMU Sans Serif")

#let dpt-cols = (
  info: rgb("#49bfe0"),
  maths: rgb("3fb4a6"),
  mktro: rgb("98bf0c"),
  dem: rgb("93117e"),
  "2sep": rgb("f29500"),
  spen: rgb("#339963"),
)

#let section-link(section, body) = {
  link((page: section.location().page(), x: 0pt, y: 0pt), body)
}

#let is-active-section(section) = {
  let active-section = utils.current-heading(level: section.level)
  active-section != none and section.location() == active-section.location()
}

#let get-sections(level, loc: auto) = {
  if loc == auto {
    // A bit of a hack, but it works.
    let active-section = utils.current-heading(level: level - 1)
    if active-section != none {
      loc = active-section.location()
    } else {
      loc = here()
    }
  }

  let parent-heading = heading.where(level: level - 1)

  let selector = heading.where(level: level)

  let previous-parents = query(parent-heading.before(loc))
  if previous-parents.len() != 0 {
    selector = selector.after(previous-parents.last().location())
  }

  let next-parents = query(parent-heading.after(loc, inclusive: false))
  if next-parents.len() != 0 {
    selector = selector.before(next-parents.first().location(), inclusive: false)
  }

  query(selector)
}

#let header(self, dpt-color: none) = {
  set align(top)
  alt-cell(fill: self.colors.primary, inset: (left: 1em), {
    set text(fill: self.colors.neutral-light.transparentize(50%), size: 0.7em)
    show: it => grid(
      columns: (1fr, auto),
      align: (start + horizon, end + horizon),
      it,
      pad(10pt, image("src/images/ENSRennes_LOGOblanc_centre.svg")),
    )
    if self.ens-rennes.named-index {
      let row(level) = context {
        show: block.with(height: 1em)
        get-sections(level)
            .map(section => {
              set text(fill: self.colors.neutral-lightest) if is-active-section(section)
              section-link(section, section.body)
            })
          .join(h(1em))
      }
      stack(
        dir: ttb,
        spacing: 0.2em,
        row(1),
        text(size: 0.8em, row(2)),
      )
    } else {
      context {
        let sections = get-sections(1)
        grid(
          columns: sections.len(),
          column-gutter: 1em,
          row-gutter: 0.2em,
          ..sections.map(section => {
            set text(fill: self.colors.neutral-lightest) if is-active-section(section)
            section-link(section, section.body)
          }),
          ..sections.map(section => {
            show: block.with(height: 1em)
            set text(fill: self.colors.neutral-lightest) if is-active-section(section)
            let subsections = get-sections(2, loc: section.location())
            for subsection in subsections {
              section-link(
                subsection,
                if is-active-section(subsection) {
                  sym.circle.filled
                } else {
                  sym.circle.stroked
                },
              )
            }
          })
        )
      }
    }
  })

  let subheader-col = rgb("#556fb2")
  if self.ens-rennes.department != none and self.ens-rennes.display-dpt {
    subheader-col = gradient.linear(dpt-cols.at(self.ens-rennes.department), dpt-cols.at(self.ens-rennes.department).lighten(60%))
  }
  alt-cell(fill: subheader-col, inset: 1em, {
    set align(horizon)
    set text(fill: self.colors.neutral-lightest)
    if self.store.title != auto {
      utils.call-or-display(self, self.store.title)
    }
  })
}

#let footer(self) = {
  set text(fill: self.colors.neutral-lightest, size: 0.8em)
  show: block.with(
    fill: self.colors.primary,
    inset: 1em,
  )
  grid(
    columns: (5fr, 4fr, 1fr),
    column-gutter: 1em,
    align: (start + horizon, start + horizon, end + horizon),
    utils.call-or-display(self, self.info.at("mini-authors", default: self.info.author)),
    utils.call-or-display(self, self.info.at("mini-title", default: self.info.title)),
    [#context utils.slide-counter.display() / #utils.last-slide-number],
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  set text(font: list-font)
  set page(foreground: align(top+left)[ #image("src/images/circles.png")])
  set list(
    marker: (
      text(self.colors.primary, sym.triangle.r.filled),
      text(self.colors.primary, sym.bullet),
      text(self.colors.primary, sym.dash.en),
    ),
  )
  if title != auto {
    self.store.title = title
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin: (top: 6em, bottom: 1.5em, x: 2em)
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(additional-content: none, ..args) = touying-slide-wrapper(self => {
  set text(font: list-font)
  set page(foreground: align(top+left)[ #image("src/images/circles.png")])
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      {
        text(size: 2em, fill: self.colors.neutral-lightest, info.title)
        linebreak()
        text(size: 1em, fill: self.colors.neutral-lightest, info.subtitle)
      }
    )
    set text(fill: self.colors.neutral-darkest)
    if info.authors != none {
      block(info.authors)
    }
    if info.institution != none {
      block(info.institution)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
    additional-content
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin: (top: 8em, bottom: 1.5em, x: 2em)
    ),
  )

  touying-slide(self: self, body)
})

#let focus-slide(config: (:), align: horizon + center, body) = touying-slide-wrapper(self => {
  set text(font: list-font)
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})

// ENS Rennes theme

#let ens-rennes-theme(
  aspect-ratio: "16-9",
  footer: none,
  info,
  ..args,
  department: none,
  display-dpt: false,
  named-index: true,
  body,
) = {
  set text(size: 20pt, font: list-font)

  assert(
    department in dpt-cols,
    message: "`department` must be one " + dpt-cols.keys().map(repr).join(", ", last: ", or ")
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(
      primary: if display-dpt and department != none {
        dpt-cols.at(department)
      } else {
         rgb("324c98")
      },
      neutral-lightest: rgb("#ffffff"),
      neutral-lighter: rgb("#ffffff"),
      neutral-light: if display-dpt and department != none {
        rgb("#F0F0F0")
      } else {
        rgb("CADDE4")
      },
      neutral-darkest: rgb("#000000"),
      neutral-darerk: rgb("#000000"),
      neutral-dark: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    info,
    ..args,
    (
      ens-rennes: (
        department: department,
        display-dpt: display-dpt,
        named-index: named-index,
      ),
    ),
  )

  body
}
