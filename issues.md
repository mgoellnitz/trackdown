# TrackDown Issues

Right now we have four areas/iterations/sprints in this issue list:

- *1.0* This should be accomplished before an 1.0 release.
- *mirror* Everything related to just mirroring issue collection is collected here
- *nth* This feature is nice to have but can be left out.
- *oos* This issue is relevant but out of the scope of this project.

## NETBEANS interoperation not working due to missing hook implementation in JGit (in progress)

*oos*

While some IDE integrations rely on the [GIT](http://git-scm.com/) command line 
tooling and thus work perfectly together with this project, NetBeans decided to 
use the [JGit](https://eclipse.org/jgit/) library, which only supports a subsets 
of the [GIT](http://git-scm.com/) hooks - and not the ones we  use here.

I already helped to add the post-commit hook which is needed by this project
and it now is part of the latest nightly builds. Interoperation with TrackDown
could not be tested so far.

## MIRRORHOOK for update of the local mirror and roadmap for mirrored issue collections

*nth*

For users of the mirror feature of collections with Redmine, GitHub, Gitlab, 
and Gogs a hook implementation should mirror the issue collection on push
to keep it updated in exactly the situations where the local machine must
be connected to the remote site - or at least somehow to the internet.

_Note_

This seems to be hard to accomplish with GIT, since there is only a `pre-push`
hook available and we would need a `post-push` hook to get the right timing
after the changes have been reflected in the remote issue tracking system.

## GRAPHICAL progress bar for iterations in roadmap (resolved)

*nth*

Not only output percentages about the progress a certain release, iteration,
or sprint has made, but also present a graphical progress bar for easier
overview about the current state.

Martin Goellnitz / Wed, 28 Dec 2016 01:13:18 [415121a80ee3a216e9a02635df34b30dacb34f73](https://github.com/mgoellnitz/trackdown/commit/415121a80ee3a216e9a02635df34b30dacb34f73)

    resolves #GRAPHICAL progress bar in roadmap

Martin Goellnitz / Wed, 28 Dec 2016 01:14:37 [30444b0522236166b34660802f12938b043935af](https://github.com/mgoellnitz/trackdown/commit/30444b0522236166b34660802f12938b043935af)

    fixes #GRAPHICAL progress bar generation in commit hook

## GITLAB offline mirror (in progress)

*mirror*

TrackDown should be capable of translating [GitLab](https://gitlab.com/) JSON 
exports of tickets to the special markdown format given here as a mirror for 
offline use.

Martin Goellnitz / Sun Nov 13 19:10:27 2016 [29eb793d1caa2e42c1f120aa31e7ceb27929ca6b](https://github.com/mgoellnitz/trackdown/commit/29eb793d1caa2e42c1f120aa31e7ceb27929ca6b)

    refs #GITLAB mirror in its first incarnation as another mirror type

Martin Goellnitz / Sun Nov 13 19:11:43 2016 [d239356055272bdd0af6cad32925bb259785717d](https://github.com/mgoellnitz/trackdown/commit/d239356055272bdd0af6cad32925bb259785717d)

    refs #GITLAB offline testing was still in place

Martin Goellnitz / Sun Nov 13 19:29:46 2016 [4940d3cf9d3182d0fe591ea82ea94d0651703ffd](https://github.com/mgoellnitz/trackdown/commit/4940d3cf9d3182d0fe591ea82ea94d0651703ffd)

    refs #GITLAB remote command to assign tickets added

Martin Goellnitz / Sun Nov 13 19:52:31 2016 [34e0dcec0c72fc0fafe0887a966e392163d6df44](https://github.com/mgoellnitz/trackdown/commit/34e0dcec0c72fc0fafe0887a966e392163d6df44)

    refs #GITLAB issues exports should at least be usable up to 100 issues

Martin Goellnitz / Tue, 9 May 2017 10:59:11 [8292cabc4822ea2ae76c8d918cda8b11de09624c](https://github.com/mgoellnitz/trackdown/commit/8292cabc4822ea2ae76c8d918cda8b11de09624c)

    refs #GITLAB remote command extended with comments, labels, and milestones

Martin Goellnitz / Sat, 20 May 2017 22:39:00 [ec300a8adf5f0c0b85af49185cbfcce7ec2b2cc0](https://github.com/mgoellnitz/trackdown/commit/ec300a8adf5f0c0b85af49185cbfcce7ec2b2cc0)

    refs #GITLAB uses paging for most listings

Martin Goellnitz / Tue, 17 Oct 2017 20:19:34 [297f1fafc5d1af16ee20c1c7bc6e97cdd6e2ef34](https://github.com/mgoellnitz/trackdown/commit/297f1fafc5d1af16ee20c1c7bc6e97cdd6e2ef34)

    refs #GITLAB - deal with newlines in a readable way

Martin Goellnitz / Wed, 8 Nov 2017 19:09:41 [a3b7df331bee8635d1c3d28af94a7d37304a660b](https://github.com/mgoellnitz/trackdown/commit/a3b7df331bee8635d1c3d28af94a7d37304a660b)

    refs #GITLAB assignee layout changed for mirror

Martin Goellnitz / Mon, 22 Jan 2018 23:03:40 [5f3734ab936b76d30773e8d5baeee2ef7091e6bc](https://github.com/mgoellnitz/trackdown/commit/5f3734ab936b76d30773e8d5baeee2ef7091e6bc)

    refs #GITLAB mirror setup streamlined

Martin Goellnitz / Tue, 23 Jan 2018 01:02:12 [e39700997dd9fe8e1b12b68a369ada295c1a2b35](https://github.com/mgoellnitz/trackdown/commit/e39700997dd9fe8e1b12b68a369ada295c1a2b35)

    refs #GITLAB now can mirror more than 100 issues per project

Martin Goellnitz / Sun, 18 Mar 2018 23:47:41 [4aa517b347ab90f70ec4ff7cc7316b184ca7c129](https://github.com/mgoellnitz/trackdown/commit/4aa517b347ab90f70ec4ff7cc7316b184ca7c129)

    refs #GITLAB mirror milestone handling fixed

Martin Goellnitz / Tue, 1 May 2018 01:36:39 [7686f336ec8e8dfe9d239d743bf379aa343547f0](https://github.com/mgoellnitz/trackdown/commit/7686f336ec8e8dfe9d239d743bf379aa343547f0)

    refs #GITLAB mirror exports comments

Martin Goellnitz / Tue, 1 May 2018 19:27:56 [c3bd366e8802bf1951f208267450c46877d92403](https://github.com/mgoellnitz/trackdown/commit/c3bd366e8802bf1951f208267450c46877d92403)

    refs #GITLAB mirror doesn't use internal IDs on the surface anymore

Martin Goellnitz / Sat, 29 Dec 2018 00:27:52 [885d8aa30c3fd3e652c660f748ffdba5a020f0d4](https://github.com/mgoellnitz/trackdown/commit/885d8aa30c3fd3e652c660f748ffdba5a020f0d4)

    refs #GITLAB migrate to API v4

Martin Goellnitz / Sun, 3 Feb 2019 23:11:04 [fce39b2ac3fb1df3ccfedc93ee99adf49cad4b2b](https://github.com/mgoellnitz/trackdown/commit/fce39b2ac3fb1df3ccfedc93ee99adf49cad4b2b)

    refs #GITLAB - fix mirror init

## GITHUB offline mirror (in progress)

*mirror*

TrackDown should be capable of translating [GitHub](https://github.com) JSON 
exports of tickets to the special markdown format given here as a mirror for 
offline use.

Martin Goellnitz / Sun Nov 13 21:19:35 2016 [35a52a9d751029ac5cbc3730ea28a3fc682663ce](https://github.com/mgoellnitz/trackdown/commit/35a52a9d751029ac5cbc3730ea28a3fc682663ce)

    refs #GITHUB mirroring in its first incarnation of yet another mirror type

Martin Goellnitz / Tue Dec 6 18:19:54 2016 [8ec2c02ebfd241b9b8599ef0fd0b3ebf763907e2](https://github.com/mgoellnitz/trackdown/commit/8ec2c02ebfd241b9b8599ef0fd0b3ebf763907e2)

    refs #GITHUB automatically discover single commit URLs for github and the others

Martin Goellnitz / Tue, 9 May 2017 22:33:40 [98a34fe224418e7b04a9057e98fdfccff62656bd](https://github.com/mgoellnitz/trackdown/commit/98a34fe224418e7b04a9057e98fdfccff62656bd)

    refs #GITHUB,BITBUCKET mirror setup clean up and reasonable defaults

Martin Goellnitz / Tue, 9 May 2017 22:52:21 [baa4e26e95d1058bb85133d78f5f495b11352f0c](https://github.com/mgoellnitz/trackdown/commit/baa4e26e95d1058bb85133d78f5f495b11352f0c)

    refs #GITHUB remote command started

Martin Goellnitz / Wed, 10 May 2017 00:57:33 [6be3ca72e57e13529ab76e4d2b792dfc39d3be33](https://github.com/mgoellnitz/trackdown/commit/6be3ca72e57e13529ab76e4d2b792dfc39d3be33)

    refs #GITHUB remote commands fixed

Martin Goellnitz / Tue, 13 Jun 2017 17:49:17 [bb8045feb16aaf7e837ba045cdfbd8c74e5bbfe8](https://github.com/mgoellnitz/trackdown/commit/bb8045feb16aaf7e837ba045cdfbd8c74e5bbfe8)

    refs #GITHUB issue parsing for newlines and milestones fixed

Martin Goellnitz / Wed, 25 Apr 2018 00:51:54 [4461150447b3766f76d985279a2c58ae47e13a9b](https://github.com/mgoellnitz/trackdown/commit/4461150447b3766f76d985279a2c58ae47e13a9b)

    refs #GITHUB remote command refactored

Martin Goellnitz / Mon, 30 Apr 2018 19:18:38 [1b4b0f0e5d5a773e520f4d979059ffb98db7234b](https://github.com/mgoellnitz/trackdown/commit/1b4b0f0e5d5a773e520f4d979059ffb98db7234b)

    refs #GITHUB comments get exported

## REDMINE offline mirror (resolved)

*mirror*

For how historical reasons I have projects with Redmine ticketing in 
use and still with relevant tickets. Some of them might even be a candidate to 
migrate to TrackDown for others it might be sufficient to get a current offline 
mirror when the repository is not available.

TrackDown should be capable of translating Redmine JSON exports of tickets to 
the special markdown format given here. 

For the mirror scenario, certain limitations are acceptable, 

For  migration scenarios the commit lists should be included and even closed 
tickets should be taken into account to not lose the relevant parts of the
project history.

Martin Goellnitz / Sun Nov 13 01:22:34 2016 [dcf643bf7b21300561013b6cd5fbf202a0567009](https://github.com/mgoellnitz/trackdown/commit/dcf643bf7b21300561013b6cd5fbf202a0567009)

    refs #REDMINE mirroring started

Martin Goellnitz / Sun Nov 13 01:51:12 2016 [de3417d6789e59219d8d9616d5498c857f33cb32](https://github.com/mgoellnitz/trackdown/commit/de3417d6789e59219d8d9616d5498c857f33cb32)

    refs #REDMINE mirror users don't have to use git for this purpose - smarter .gitignore handling alongside

Martin Goellnitz / Sun Nov 13 02:48:36 2016 [7211c3ce7b6f7bed464fa6c866239b5ced3bd4e2](https://github.com/mgoellnitz/trackdown/commit/7211c3ce7b6f7bed464fa6c866239b5ced3bd4e2)

    refs #REDMINE mirror shoud overwrite issue collection and no always append

Martin Goellnitz / Sun Nov 13 12:21:00 2016 [a82c03fdf6356ef4079446fe7f3d75cae80124d7](https://github.com/mgoellnitz/trackdown/commit/a82c03fdf6356ef4079446fe7f3d75cae80124d7)

    refs #REDMINE mirror command should be named mirror and the old sync command keep that name

Martin Goellnitz / Sun Nov 13 12:55:45 2016 [a745c43eb4a444bae91dc15d2b601f78e63e8722](https://github.com/mgoellnitz/trackdown/commit/a745c43eb4a444bae91dc15d2b601f78e63e8722)

    refs #REDMINE mirror now extracts more details from the original tickets

Martin Goellnitz / Thu Dec 8 02:36:38 2016 [ed8b05966665e9efe4bfe7e1ba70f0c4115f2296](https://github.com/mgoellnitz/trackdown/commit/ed8b05966665e9efe4bfe7e1ba70f0c4115f2296)

    refs #REDMINE output enhanced when content is html-ish and multiple projects can be mirrored

Martin Goellnitz / Thu Dec 8 02:43:49 2016 [83d19594298213d5b285f49aee4e3d2b293eb90d](https://github.com/mgoellnitz/trackdown/commit/83d19594298213d5b285f49aee4e3d2b293eb90d)

    refs #REDMINE needed documentation hint for multi-project mirror

Martin Goellnitz / Sat Dec 17 00:52:30 2016 [fd5697f0f61a1106446586868706f52d4c0b0ce3](https://github.com/mgoellnitz/trackdown/commit/fd5697f0f61a1106446586868706f52d4c0b0ce3)

    refs #REDMINE exports priority to issue collection mirror

Martin Goellnitz / Fri Dec 23 01:09:35 2016 [257a45fb29231a28def2c08ba3c196f58f96d83b](https://github.com/mgoellnitz/trackdown/commit/257a45fb29231a28def2c08ba3c196f58f96d83b)

    refs #REDMINE migration support with custom export file

Martin Goellnitz / Wed, 28 Dec 2016 01:57:29 [01c5211aa1ff2a2056439a1ee1c73ddc7d8ece98](https://github.com/mgoellnitz/trackdown/commit/01c5211aa1ff2a2056439a1ee1c73ddc7d8ece98)

    resolves #REDMINE migration to trackdown now tested to be working

## BITBUCKET issue tracker offline mirror (in progress)

*mirror*

TrackDown should be capable of translating [Bitbucket.org](https://bitbucket.org/) 
JSON exports of tickets to the special markdown format given here as a mirror for 
offline use.

Martin Goellnitz / Sat Dec 3 13:05:30 2016 [53f1165e8e009ca843909c6d67daaabc7a318f6c](https://github.com/mgoellnitz/trackdown/commit/53f1165e8e009ca843909c6d67daaabc7a318f6c)

    refs #BITBUCKET support started in a first basic version

Martin Goellnitz / Tue, 9 May 2017 22:33:40 [98a34fe224418e7b04a9057e98fdfccff62656bd](https://github.com/mgoellnitz/trackdown/commit/98a34fe224418e7b04a9057e98fdfccff62656bd)

    refs #GITHUB,BITBUCKET mirror setup clean up and reasonable defaults

Martin Goellnitz / Wed, 25 Apr 2018 00:41:24 [2d5495a939c1d81f4b6e55c22cf015c3062092c1](https://github.com/mgoellnitz/trackdown/commit/2d5495a939c1d81f4b6e55c22cf015c3062092c1)

    refs #BITBUCKET remote command addd

Martin Goellnitz / Mon, 30 Apr 2018 23:50:35 [cc285b530edc77f94b6e450e89bd9118ada298e7](https://github.com/mgoellnitz/trackdown/commit/cc285b530edc77f94b6e450e89bd9118ada298e7)

    refs #BITBUCKET mirror exports comments

## GOGS and gitea offline mirror (in progress)

*mirror*

TrackDown should be capable of translating [gitea](https://gitea.io/) JSON 
exports of tickets to the special markdown format given here as a mirror for 
offline  use. Publicly available instances are [CodeBerg][https://codeberg.org/]
and [Pikacode](https://v2.pikacode.com/), where we now should use 
[CodeBerg][https://codeberg.org/] as the default public backend.

This also should relate to the not that active project 
[gogs](https://gogs.io/).

Martin Goellnitz / Sat Dec 3 02:56:16 2016 [e438fa86d8f6d112565899dcbfec466001ea13b4](https://github.com/mgoellnitz/trackdown/commit/e438fa86d8f6d112565899dcbfec466001ea13b4)

    refs #GOGS support initiated with reasonable output in the first step

Martin Goellnitz / Sat Dec 3 03:03:44 2016 [58a55bc60edc6b451722b6d96b7c598ff8a39522](https://github.com/mgoellnitz/trackdown/commit/58a55bc60edc6b451722b6d96b7c598ff8a39522)

    refs #GOGS related commands missed their documentation

Martin Goellnitz / Tue, 9 May 2017 22:35:08 [bad2ffc8bc29acfafb9a044da43df062ade2dfb5](https://github.com/mgoellnitz/trackdown/commit/bad2ffc8bc29acfafb9a044da43df062ade2dfb5)

    refs #GOGS remote command added

Martin Goellnitz / Mon, 30 Apr 2018 21:55:51 [8484d90272c85bbd56dbf55a101776a649cb2fff](https://github.com/mgoellnitz/trackdown/commit/8484d90272c85bbd56dbf55a101776a649cb2fff)

    refs #GOGS mirror exports comments

Martin Goellnitz / Tue, 30 Apr 2019 11:01:23 [ec496740ac1688533bb73c46a3500bad100297f3](https://github.com/mgoellnitz/trackdown/commit/ec496740ac1688533bb73c46a3500bad100297f3)

    refs #GOGS - honor that gitea now is the primary choice over gogs

Martin Goellnitz / Tue, 30 Apr 2019 11:10:01 [df6f4204e5f5b711ca1d1c864e6b146d0a52092f](https://github.com/mgoellnitz/trackdown/commit/df6f4204e5f5b711ca1d1c864e6b146d0a52092f)

    refs #GOGS - add codeberg as the default for gitea

Martin Goellnitz / Tue, 30 Apr 2019 11:15:28 [1efd88ff04ba50baf002ee501e4433828b65fcef](https://github.com/mgoellnitz/trackdown/commit/1efd88ff04ba50baf002ee501e4433828b65fcef)

    refs #GOGS - fix tests to reflect new priorities

Martin Goellnitz / Tue, 30 Apr 2019 11:17:02 [9b72d46bc405fae922dcf413fdc6a4a1a95103bd](https://github.com/mgoellnitz/trackdown/commit/9b72d46bc405fae922dcf413fdc6a4a1a95103bd)

    refs #GOGS - fix tests to reflect new priorities

Martin Goellnitz / Tue, 30 Apr 2019 11:21:36 [be4dfc8aa1b34415a3425259f6ada48f9f87d26e](https://github.com/mgoellnitz/trackdown/commit/be4dfc8aa1b34415a3425259f6ada48f9f87d26e)

    refs #GOGS - fix tests to reflect new priorities
