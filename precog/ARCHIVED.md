# Archived: `precog/`

The 2013-era static marketing site for the PreCog product concept, plus three
Rails skeletons (`blog/`, `socify/`) and one Google App Engine stub
(`precog-security/`).

## Status

**Not built, not tested, not deployed, not maintained.** Nothing in CI builds,
tests or lints this tree. There is no lockfile for either Rails skeleton.

## Front-end dependencies are all EOL — do not reuse them

`index.html` is a static page, so there is no build to fail, but it is *not* a
safe starting point. It pins libraries that are years past end of life:

| Library | Pin | Problem |
| --- | --- | --- |
| jQuery | 1.8.3 (2012) | Pre-dates every fix in 1.12+/3.x, including the `htmlPrefilter` XSS (CVE-2015-9251) and prototype-pollution fixes (CVE-2019-11358). |
| Bootstrap | 3.0.3 (2013) | EOL; 3.x has known XSS fixes only up to 3.4.1. |
| jQuery Isotope | 1.5.25 | EOL open-source core. |

`js/` additionally carries copy-pasted third-party sources with no version
pinning, no integrity checking and no upstream attribution headers, which is
why they are a standing supply-chain liability rather than a dependency:

| File | Origin | Note |
| --- | --- | --- |
| `js/jquery-scrolltofixed.js` | jquery.scrolltofixed plugin | Largest vendored file; unmodified upstream copy. |
| `js/wow.js` | WOW.js | |
| `js/jquery.easing.1.3.js` | jQuery Easing v1.3 | |
| `js/respond-1.1.0.min.js`, `js/html5shiv.js`, `js/html5element.js` | Respond.js / HTML5Shiv / html5element.js | IE8 shims; no-ops in every browser this project still targets. |
| `js/classie.js` | Classie | Required by WOW.js. |

If this site is ever revived, replace every pin above with current versions
served from a CDN with a `subresource-integrity` hash, and delete `js/` rather
than carrying another copy of third-party code in-tree.

The maintained application is [`../todo/`](../todo/).