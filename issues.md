# TrackDown Issues

Right now, we have four areas/iterations/sprints in this issue list:

- *nth*   This feature is very nice to have, but also can be left out.
- *clean* Clean up the code for portability, readability and resource consumption.
- *oos*   This issue is relevant but out of the scope of this project.
- *fix*   Bugfixing topics.


## NETBEANS interoperation not working due to missing hook implementation in JGit (resolved)

*oos*

While some IDE integrations rely on the [GIT](http://git-scm.com/) command line
tooling and thus work perfectly together with this project, NetBeans decided to
use the [JGit](https://eclipse.org/jgit/) library. Until this ticket git
addressed, it only supported a subset of the [GIT](http://git-scm.com/) hooks -
and not the one we use here.

I already helped in adding the post-commit hook which is needed by this project
to [JGit](https://eclipse.org/jgit/). Some years later the respective version
got integrated into NetBeans 11.3. Sadly JGIT [JGit](https://eclipse.org/jgit/)
doesn't like symbolic links for the hook files, which we still would prefer.


## MIRRORHOOK for update of the local mirror and roadmap for mirrored issue collections

*nth*

For users of the mirror feature of collections with Redmine, GitHub, GitLab,
and Gogs a hook implementation should mirror the issue collection on push
to keep it updated in exactly the situations where the local machine must
be connected to the remote site - or at least somehow to the internet.

_Note_

This seems to be hard to accomplish with GIT, since there is only a `pre-push`
hook available, and we would need a `post-push` hook to get the right timing
after the changes have been reflected in the remote issue tracking system.


## GRAPHICAL progress bar for iterations in roadmap (resolved)

*nth*

Do not only output percentages about the progress of a certain release,
iteration, or sprint has made, but also present a graphical progress bar for
easier overview about the current state.

Martin Goellnitz / Wed, 28 Dec 2016 01:13:18 [415121a80ee3a216e9a02635df34b30dacb34f73](https://github.com/mgoellnitz/trackdown/commit/415121a80ee3a216e9a02635df34b30dacb34f73)

    resolves #GRAPHICAL progress bar in roadmap

Martin Goellnitz / Wed, 28 Dec 2016 01:14:37 [30444b0522236166b34660802f12938b043935af](https://github.com/mgoellnitz/trackdown/commit/30444b0522236166b34660802f12938b043935af)

    fixes #GRAPHICAL progress bar generation in commit hook


## BACKSLASHES in some regular expressions should be removed (in progress)

*clean*

Scattered around the code, we find regular expressions using backslashes at
places where they must not be present. GNU grep ignores these, but produces a
warning message. Debian again hides this error message. We should fix the
regular expressions instead of relying on the hiding of the messages.

Martin Goellnitz / Sun, 28 Jul 2024 21:29:55 [36b3f195707e9516b9b00ee4162b25bbb362109a](https://github.com/mgoellnitz/trackdown/commit/36b3f195707e9516b9b00ee4162b25bbb362109a)

    refs #BACKSLASHES - Unhide warning message for Debian to discover defective regular expressions

Martin Goellnitz / Sun, 28 Jul 2024 21:43:22 [d504d06e74afea9461f0e4bca44bf8a2ba83dba8](https://github.com/mgoellnitz/trackdown/commit/d504d06e74afea9461f0e4bca44bf8a2ba83dba8)

    refs #BACKSLASHES fix regular expressions when using grep


## PORTABILITY of shell code (in progress)

*clean*

The code explicitly and silently relies on some bash features, which is not
necessary and could be replaced by code relying on less resource hungry shell
implementation, especially for implicitly called scripts like the hook.

Martin Goellnitz / Thu, 1 Jan 2026 22:22:20 [8dbe2633e98a7fc525386b02e66256190f779a4e](https://codeberg.org/backendzeit/trackdown/commit/8dbe2633e98a7fc525386b02e66256190f779a4e)

    refs #PORTABILITY - replace backticks

Martin Goellnitz / Thu, 1 Jan 2026 23:22:14 [55da149aded1e6cbb93b973ebae215241c26b204](https://codeberg.org/backendzeit/trackdown/commit/55da149aded1e6cbb93b973ebae215241c26b204)

    refs #PORTABILITY - figure current branch easier and remove unused code

Martin Goellnitz / Thu, 1 Jan 2026 23:50:11 [52b0c2742e2956ff0b6e5a059d79bf908669d687](https://codeberg.org/backendzeit/trackdown/commit/52b0c2742e2956ff0b6e5a059d79bf908669d687)

    refs #PORTABILITY - fix ignore file handling


## ENHANCE signal-to-noise-ration of output

Since TrackDown is in part a wrapper for some compilations of DVCS commands,
some of the product output, which is not helpful from the outside perspective.
Thus, hiding those output doesn't lose information but enhances focus.


## NUMBER of empty lines between tickets should be preserved (resolved)

*fix*

Mostly, we like to have two empty lines between ticket blocks in the issues file
regardless which parts of the supported details and features of the file format
are in use. But of course, the overall code most also deal with situation where
there is only one empty line.

Martin Goellnitz / Sat, 3 Jan 2026 03:38:52 [48c4fe69e63df53d60d25a7cb3c618b5aed13abf](https://codeberg.org/backendzeit/trackdown/commit/48c4fe69e63df53d60d25a7cb3c618b5aed13abf)

    Resolves #NUMBER of empty lines preserving
