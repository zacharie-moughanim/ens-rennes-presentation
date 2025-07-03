#import "@preview/touying:0.6.1": *
#import "custom-blocks.typ" : *

#let alt_cell = block.with(width: 100%, height: 2.5em, above: 0pt, below: 0pt, breakable: false)

#let list-font = ("Univers", "New Computer Modern Sans", "CMU Sans Serif")

#let dpt-cols = (info: rgb("#254d58"),
               maths: rgb("3fb4a6"),
               mktro: rgb("98bf0c"),
               dem: rgb("93117e"),
               "2sep": rgb("f29500"),
               spen: rgb("#339963"))

#let nearest-heading(level: auto) = {
  let prec-heading = query(selector(heading.where(level:level))).filter(h => h.location().page() <= here().page())
  let next-heading = query(selector(heading.where(level:level))).filter(h => h.location().page() > here().page())
  return (prec-heading.at(-1, default:none), next-heading.at(0, default:none))
}

#let previous-heading(level: auto, loc) = {
  let prec-heading = query(selector(heading.where(level:level))).filter(h => h.location().page() <= loc.page())
  return prec-heading.at(-1, default:none)
}

#let display-header(heading, body:none) = if body == none {
  link((page:heading.location().page(), x:0pt, y:0pt), heading.body)
} else {
  link((page:heading.location().page(), x:0pt, y:0pt), body)
}

#let header(self, dpt-color:none) = {
  {
    set align(top)
    alt_cell.with(fill: self.colors.primary, inset:(left:1em))([
      #let display-logo = align(right + horizon,
        if self.ens-rennes.display-dpt and self.ens-rennes.department == none {
          image("src/images/ens-logo-main.svg", height: 100%)
        } else {
          image("src/images/ens-logo-dpt.svg", height: 100%)
        }
      )
      #if self.ens-rennes.named-index {
        stack(dir:ltr,
          [#set align(horizon)
          #set align(left)
          #set text(fill: self.colors.neutral-light, size: .7em)
          #context{ // FIXME: sometimes get the `message layout did not converge within five attempts`
            let (cur-heading, next-heading) = nearest-heading(level:1)
            let cur-subheading = utils.current-heading(level:2)
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
            let subsections = query(heading).filter(h => h.level == 2 and previous-heading(level:1, h.location()) == cur-heading)
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
        ],display-logo)
      } else {
        set align(horizon)
        set align(left)
        context { // FIXME: sometimes get the `message layout did not converge within five attempts`
          let display-section = ()
          let cur-heading = utils.current-heading(level:1)
          let cur-subheading = utils.current-heading(level:2)
          let sections = query(heading.where(level: 1))
          set text(fill: self.colors.neutral-light, size: .7em)
          for section in sections {
            let subsections = query(heading).filter(h => h.level == 2 and previous-heading(level:1, h.location()) == section)
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
    ])
    let subheader-col = rgb("#556fb2")
    if self.ens-rennes.department != none and self.ens-rennes.department in dpt-cols and self.ens-rennes.display-dpt {
      subheader-col = gradient.linear(dpt-cols.at(self.ens-rennes.department), dpt-cols.at(self.ens-rennes.department).lighten(60%))
    }
    alt_cell.with(fill: subheader-col, inset: 1em)([
      #set align(horizon)
      #set text(fill: self.colors.neutral-lightest, size: .7em)
      #set text(size: 1.5em)
      #if self.store.title != auto {
        utils.call-or-display(self, self.store.title)
      }
    ])
  }
}

#let footer(self) = {
  set align(bottom + left)
  set text(fill: self.colors.neutral-lightest, size: .8em)
  stack(dir:ltr,
    block.with(width: 50%, height: 100%, above: 0pt, below: 0pt, breakable: false, fill: self.colors.primary, inset: 1em)([
    #set align(horizon)
    #show: pad.with(.4em)
    #if "mini-authors" in self.info {
      utils.call-or-display(self, self.info.mini-authors)
    } else {
      utils.call-or-display(self, self.info.author)
    }
    ]),
    block.with(width: 50%, height: 100%, above: 0pt, below: 0pt, breakable: false, fill: self.colors.primary, inset: 1em)([
    #set align(right)
    #set align(horizon)
    #if "mini-title" in self.info {
      utils.call-or-display(self, self.info.mini-title)
    } else {
      utils.call-or-display(self, self.info.title)
    }
    #h(1fr)
    #context {utils.slide-counter.display() + " / " + utils.last-slide-number} // FIXME: sometimes get the `message layout did not converge within five attempts`
    ])
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  set text(font: list-font)
  set page(foreground: align(top+left)[ #image("src/images/circles.png")])
  set list(marker:(text(self.colors.primary, sym.triangle.r.filled), text(self.colors.primary, [•]), text(self.colors.primary, [–])))
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

#let title-slide(additional-content:none, ..args) = touying-slide-wrapper(self => {
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
  set text(size: 20pt, font:list-font)

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
