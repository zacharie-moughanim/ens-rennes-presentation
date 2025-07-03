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
  info: rgb("#254d58"),
  maths: rgb("3fb4a6"),
  mktro: rgb("98bf0c"),
  dem: rgb("93117e"),
  "2sep": rgb("f29500"),
  spen: rgb("#339963"),
)

#let surrounding-headings(level: auto) = {
  let headings = query(heading.where(level: level))
  let previous-headings = headings.filter(h => h.location().page() <= here().page())
  let next-headings = headings.filter(h => h.location().page() > here().page())
  return (
    previous-headings.at(-1, default: none),
    next-headings.at(0, default: none),
  )
}

#let previous-heading(level: auto, loc) = {
  let headings = query(heading.where(level: level))
  let prec-headings = headings.filter(h => h.location().page() <= loc.page())
  return prec-headings.at(-1, default: none)
}

#let display-header(heading, body: none) = {
  let dest = (page: heading.location().page(), x: 0pt, y: 0pt)
  if body == none {
    link(dest, heading.body)
  } else {
    link(dest, body)
  }
}

#let header(self, dpt-color: none) = {
  set align(top)
  alt-cell(fill: self.colors.primary, inset: (left: 1em), {
    let display-logo = align(
      right + horizon,
      pad(10pt, image("src/images/ens-rennes.svg"))
    )
    if self.ens-rennes.named-index {
      stack(
        dir: ltr,
        {
          set align(horizon)
          set align(start)
          set text(fill: self.colors.neutral-light, size: 0.7em)
          // FIXME: Sometimes get the message "layout did not converge within five attempts".
          context {
            let (cur-heading, next-heading) = surrounding-headings(level: 1)
            let cur-subheading = utils.current-heading(level: 2)
            let sections = query(heading.where(level: 1))
            for section in sections {
              if cur-heading == section {
                text(self.colors.neutral-lightest, display-header(section))
              } else {
                text(self.colors.neutral-light.transparentize(50%), display-header(section))
              }
              h(1em)
            }
            linebreak()
            set text(fill: self.colors.neutral-light, size: .8em)
            let subsections = query(heading).filter(h => h.level == 2 and previous-heading(level: 1, h.location()) == cur-heading)
            for subsection in subsections {
                if cur-subheading == subsection {
                  text(self.colors.neutral-lightest, display-header(subsection))
                } else {
                  text(self.colors.neutral-light.transparentize(50%), display-header(subsection))
                }
                h(1em)
            }
            if subsections == () []
          }
        },
        display-logo,
      )
    } else {
      set align(horizon)
      set align(left)
      // FIXME: Sometimes get the message "layout did not converge within five attempts".
      context {
        let display-section = ()
        let cur-heading = utils.current-heading(level: 1)
        let cur-subheading = utils.current-heading(level: 2)
        let sections = query(heading.where(level: 1))
        set text(fill: self.colors.neutral-light, size: 0.7em)
        for section in sections {
          let subsections = query(heading).filter(h => h.level == 2 and previous-heading(level: 1, h.location()) == section)
          display-section.push([
            #if cur-heading == section {
              text(self.colors.neutral-lightest, display-header(section))
            } else {
                text(self.colors.neutral-light.transparentize(50%), display-header(section))
            }\
            #for subsection in subsections {
              if cur-subheading == subsection {
                display-header(subsection, body:sym.circle.filled)
              } else {
                display-header(subsection, body:sym.circle)
              }
            }
          ])
        }
        stack(dir:ltr, spacing:1fr, ..display-section,display-logo)

      }
    }
  })
  let subheader-col = rgb("#556fb2")
  if self.ens-rennes.department != none and self.ens-rennes.department in dpt-cols and self.ens-rennes.display-dpt {
    subheader-col = gradient.linear(dpt-cols.at(self.ens-rennes.department), dpt-cols.at(self.ens-rennes.department).lighten(60%))
  }
  alt-cell(fill: subheader-col, inset: 1em, {
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: 0.7em)
    set text(size: 1.5em)
    if self.store.title != auto {
      utils.call-or-display(self, self.store.title)
    }
  })
}

#let footer(self) = {
  set align(bottom + left)
  set text(fill: self.colors.neutral-lightest, size: 0.8em)
  stack(
    dir: ltr,
    block(width: 50%, height: 100%, above: 0pt, below: 0pt, breakable: false, fill: self.colors.primary, inset: 1em, {
      set align(horizon)
      show: pad.with(0.4em)
      if "mini-authors" in self.info {
        utils.call-or-display(self, self.info.mini-authors)
      } else {
        utils.call-or-display(self, self.info.author)
      }
    }),
    block(width: 50%, height: 100%, above: 0pt, below: 0pt, breakable: false, fill: self.colors.primary, inset: 1em, {
      set align(right)
      set align(horizon)
      if "mini-title" in self.info {
        utils.call-or-display(self, self.info.mini-title)
      } else {
        utils.call-or-display(self, self.info.title)
      }
      h(1fr)
      // FIXME: Sometimes get the message "layout did not converge within five attempts".
      [#context utils.slide-counter.display() / #utils.last-slide-number]
    })
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
