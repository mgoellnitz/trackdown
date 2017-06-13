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

## GOGS and gitea offline mirror (in progress)

*mirror*

TrackDown should be capable of translating [gogs](https://gogs.io/) JSON 
exports of tickets to the special markdown format given here as a mirror for 
offline  use. This also adds [gitea](https://gitea.io/) and has a public 
instance at [Pikacode](https://v2.pikacode.com/), which can be used as a 
default.

Martin Goellnitz / Sat Dec 3 02:56:16 2016 [e438fa86d8f6d112565899dcbfec466001ea13b4](https://github.com/mgoellnitz/trackdown/commit/e438fa86d8f6d112565899dcbfec466001ea13b4)

    refs #GOGS support initiated with reasonable output in the first step

Martin Goellnitz / Sat Dec 3 03:03:44 2016 [58a55bc60edc6b451722b6d96b7c598ff8a39522](https://github.com/mgoellnitz/trackdown/commit/58a55bc60edc6b451722b6d96b7c598ff8a39522)

    refs #GOGS related commands missed their documentation

Martin Goellnitz / Tue, 9 May 2017 22:35:08 [bad2ffc8bc29acfafb9a044da43df062ade2dfb5](https://github.com/mgoellnitz/trackdown/commit/bad2ffc8bc29acfafb9a044da43df062ade2dfb5)

    refs #GOGS remote command added

## ASSIGNMENT of issues should be part of the format and tooling (resolved)

*1.0*

We need a facility to deal with assignments of tickets to illustrate, who
is currently working on an issue at least as an optional part of the format.

Additionally some support in the tooling is needed to list issues assigned
to the current user


Martin Goellnitz / Sun Nov 13 14:47:12 2016 [0aaf357d1474a3877db9da977b9aadba7d9ed6a5](https://github.com/mgoellnitz/trackdown/commit/0aaf357d1474a3877db9da977b9aadba7d9ed6a5)

    refs #ASSIGNMENT of issues to me now listable

## COPY release notes. (in progress)

*1.0*

When closing a release or sprint, it should be possible to copy all the resolved
issues to a new Markdown file to remove them from the issue 
collection and have a contribution to release notes.

Martin Goellnitz / Tue Dec 6 00:40:57 2016 [54ffed9d2f60172195089bdbd13c6bca4828c98b](https://github.com/mgoellnitz/trackdown/commit/54ffed9d2f60172195089bdbd13c6bca4828c98b)

    refs #COPY release notes

Martin Goellnitz / Tue Dec 6 00:53:17 2016 [42a073d10652ea3d3c72d82b72ca0f77c7511bb0](https://github.com/mgoellnitz/trackdown/commit/42a073d10652ea3d3c72d82b72ca0f77c7511bb0)

    refs #COPY command needs documentation

Martin Goellnitz / Sun Dec 18 19:47:41 2016 [3afd354f7313dbe442aad2eda95b6352d1df196b](https://github.com/mgoellnitz/trackdown/commit/3afd354f7313dbe442aad2eda95b6352d1df196b)

    refs #COPY of the release notes should reside next to roadmap file

Martin Goellnitz / Fri Dec 23 01:30:25 2016 [b88c3678c4daff263afba4a6a672bba904f37103](https://github.com/mgoellnitz/trackdown/commit/b88c3678c4daff263afba4a6a672bba904f37103)

    refs #COPY issues fixed after file discovery change

## ROADMAP should show percentage for issues already started (resolved)

*1.0*

As with the number of resolved issues there should be a second value for the 
work in progress.

Martin Goellnitz / Tue Nov 8 20:03:51 2016 [2535f73db2aca2049a018f5b705e2604dc98f28b](https://github.com/mgoellnitz/trackdown/commit/2535f73db2aca2049a018f5b705e2604dc98f28b)

    refs #ROADMAP output enhancement

Martin Goellnitz / Wed Nov 9 00:55:22 2016 [0bd7768acc26577da36ae808e21d72deb70452e7](https://github.com/mgoellnitz/trackdown/commit/0bd7768acc26577da36ae808e21d72deb70452e7)

    resolve #ROADMAP enhancements

## SETUP tracking repository symmetrically (resolved)

*1.0*

The local tracking branch with its special checkout should be setup symmetrically
to ther root repository checkout with simple push style and user and email
set up locally.

Martin Goellnitz / Wed Nov 9 01:42:57 2016 [674b85ec7bebbf36618b000098c9195893fc3f90](https://github.com/mgoellnitz/trackdown/commit/674b85ec7bebbf36618b000098c9195893fc3f90)

    resolve #SETUP tracking repository symmetrically

## SYNCHRONIZE roadmap also on unhandled commits (resolved)

*1.0*

The roadmap file should be updated on every commit since there might be
changes in the issue collection file not produced by the commit hook script - 
e.g. by manual modification - which still might affect the roadmap.

Martin Goellnitz / Wed Nov 9 01:26:57 2016 [b5187ae2af3e8718fc943ccc21bbe1fd91458174](https://github.com/mgoellnitz/trackdown/commit/b5187ae2af3e8718fc943ccc21bbe1fd91458174)

    refs #SYNCHRONIZE roapmap on every commit

Martin Goellnitz / Wed Nov 9 01:32:00 2016 [4802cb811866529bcb52b100693219a206fa1e43](https://github.com/mgoellnitz/trackdown/commit/4802cb811866529bcb52b100693219a206fa1e43)

    resolve #SYNCHRONIZE roadmap also on otherwise unhandled commits

## ROOT directory of the source code must be a valid roadmap and issue file location (resolved)

*1.0*

Due to forced set of symbolic links in the root directory of the source code
respository to the roadmap and issue collection file, the 'use' step fails.

Martin Goellnitz / Tue Sep 6 21:29:12 2016 +0200

    refs #ROOT - make root directory of source code a valid place for the issue collection file and roadmap file

## UPDATE command for the commit hook (resolved)

*1.0*

Add an update command so that the commit hook can be updated alongside the
tool script to be in sync.

## HASH of the commit should be part of the listing (resolved)

*1.0*

When adding a commit note to the issue collection file, the hash of that
commit should be part of the message alongside with the date and author.

## PREFIX hashes in commit notes to form a URL (resolved)

*1.0*

Many git implementations provide links to single commits with their changes
and other information. Provide configuration options for TrackDown to extend
the commit hashes to full URLs when adding a commit note to the issues 
collection file resulting in callable HTTP-links.

Martin Goellnitz / Tue Nov 8 19:22:15 2016  (commit 7931fbc6a6379032e19733af3f343261989c1108)

    refs #PREFIX commit hashes to form clickable URLs

Martin Goellnitz / Tue Nov 8 19:43:10 2016 [0d0f42e3606654c2b036113e411ee313ce4f9493](https://github.com/mgoellnitz/trackdown/commit/0d0f42e3606654c2b036113e411ee313ce4f9493)

    resolve #PREFIX commit hashes to form clickable links

## MULTIISSUE There can be only one issue per commit. (resolved)

*1.0*

Right now we only support the extraction of one issues ID per [GIT](http://git-scm.com/) commit.

Martin Goellnitz Tue Dec 6 18:20:48 2016

    refs #MULTIISSUE command can be issues in the commit message

Martin Goellnitz Tue Dec 6 18:52:52 2016

    fixes #MULTIISSUE needed documentation and a fix

## MERCURIAL support should be added with the same functionality as GIT (resolved)

*1.0*

Like the scenario where TrackDown is used with a special branch within your
GIT repository, this setup can also be achieved with Mercurial / hg.

Martin Goellnitz Wed Dec 7 00:46:36 2016

    refs #MERCURIAL flavour of this projects started - hook equivalent completely missing

Martin Goellnitz Wed Dec 7 01:57:12 2016

    refs #MERCURIAL got its own hook implementation

Martin Goellnitz Thu Dec 8 11:56:56 2016

    refs #MERCURIAL ignore file fixed

Martin Goellnitz Sat Dec 17 21:17:49 2016

    refs #MERCURIAL repositories may also be the root of mirrors

Martin Goellnitz / Mon Dec 26 23:36:25 2016 [91709650383e188b218064f12ac068eff8c9e4fa](https://github.com/mgoellnitz/trackdown/commit/91709650383e188b218064f12ac068eff8c9e4fa)

    resolves #MERCURIAL now even shares most of the hook code with the git scenario
