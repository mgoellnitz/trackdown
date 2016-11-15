# TrackDown

[![Latest Release](https://img.shields.io/github/release/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/releases/latest)
[![License](https://img.shields.io/github/license/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/blob/master/LICENSE)

Issue Tracking with plain [Markdown][markdown].

In short: You are missing the "git clone" for your tickets from [GitLab][gitlab], 
[GitHub][github] or [Bitbucket][bitbucket] where we already have this for 
code and wiki?

You need issue tracking which works for distributed and potentially disconnected
situations together with your distributed version control [GIT][git] and e.g. 
also your distributed wiki editing through [GIT][git] as well?

Then this here is for you!

It is not intended for large, permanently online or connected teams and heavy 
flows of tickets though, since you will be having only one file with plain 
[Markdown][markdown] with your issues - and optionally other stuff - collected 
in it.


# Design

While TrackDown does not define an issue related workflow, it has some intended 
workflow elements which are supported:

The issues are defined and maintained in a single [Markdown][markdown] file 
following the format given here.

The [GIT][git] post-commit hook of TrackDown reads the commit messages and 
modifies that issue collection if your commit messages relate to some of the 
issues.

Additionally a roadmap file is automatically maintained for your tickets.
This roadmap file groupd the issue headline in groups according to their
version label and illustrated progress counting issues in progress and resolved
issues.

The issue collection this way is held local on your machine and not remote in 
the database of a tracking system. (Which is something also [Fossil][fossil] 
supports.) Like with the source code, it is pushed to remote repositories if 
needed (or possible). The simple [Markdown][markdown] format and the usage of 
[GIT][git] as a backend support distributed, shared editing and later merging of 
the issues and the related notes in the issue collection. (This is where the 
parallel with [Fossil][fossil] ends).


# The Format

While sticking to only partly structured [Markdown][markdown] the following 
elements should be maintainable with TrackDown:

- ID
- Title
- Status
- Commits
- Target Version
- Severity
- Affected Versions
- Description
- Comments

These fields are mapped to the following source structure

```
  ## ID Title (status)

  *Target Version (optional)* - Currently assigned to: `me` (optional)

  ### severity (optional) priority (optional)

  affected versions: 1.0, 1.1 (optional)

  ### Description (optional)

  description

  ### Comments (optional)

  comments (structured)

  ### Commits (auto generated)

  The headline commits at level three is optional. The commit messages are 
  inserted just as the last part of the issue's level two text area.
```

The really fixed non optional parts of this are

```
  ## ID Title (status)

  (Commit messages inserted here before the next ticket)
```


## Field Values

### ID

Any combination of (english) upper- and lower-case letters and digits.

### Title

Any expressible in Markdown.

### Status

Anything expressible in Markdown. Automatically set values are "in progress" if
you start committing for a certain ID and "resolved", if you are using a prefix
of "fixes ID" or "resolves ID".

Other intended values include "new", where the issue is just files, and "closed"
when the solution is brought into production.

### Target Version

Onyl digits, letters and dots. No spaces allowed.

```
  Future-Work Will be evaluated to calculate your project's roadmap
```

### Description

Anything expressible in Markdown.

### Affected Versions

Anything expressible in Markdown. Is expected to describe which version are
affected by the issue (if this is possible to say).

### Comments

Anything expressible in Markdown.

### Severity

Anything expressible in Markdown.


# Setup

There are two ways to setup TrackDown: Have the issues file integrated in your
source code repository, or place it in a arbitrary place of your chosing.

The first - default - way is to use it in a separate branch of your source code 
repository. It is kept visible and editable through a symbolic link at the
root level of the source code repository. Of course this file is touched
automatically via commits to your sourcecode through the post-commit hook of
TrackDown.

The second way is to use the file at a different location - e.g. in the wiki of
the project instead of the source code repository, which is described later.

In both cases the automatically maintained roadmap file resides next to the
issue collection file.

## Initialize the Repository

If you want to track the issues in a TrackDown branch of your source code 
repository and not in any other location of your chosing, you need to modify the 
[GIT][git] repository accordingly. Your source code repository must contain at 
least one commit for this to work. To initialize a [GIT][git] repository that 
way, call the script

```
  trackdown.sh init
```

This creates the TrackDown thread for the issue tracking. You have to manually
propagate this thread to your upstream repositories. TrackDown does not
interfere with your remote workflow.

```
  git push original trackdown
```

Initialization must only be executed once for a repository and all of its forks 
and clones.

If you want to use the issue collection file from a different location, leave
out this step.

## Repository Integration

Regardless of the location of the issue collection file, for each clone of the
repository you have to set up the TrackDown tooling to be able to use it
integrated with your source code [GIT][git] commits.

To start using TrackDown for the respective clone you have to issue

```
  trackdown.sh use
```

when using the TrackDown branch in the source code repository or

```
  trackdown.sh use <path/to/issues.md>
```

like in

```
  trackdown.sh use ../wiki/issues.md
```

when using TrackDown with the issue collection file at a different location.
Automatic commit and push (see below) will be switched of in the latter case.

This creates a gitignored link issues.md in the root directory of your project
pointing to the issue collection file and it will configure a post-commit hook
for [GIT][git].

After this step you can edit the issue collection file following the format
mentioned here.


# Commands in the Commit Messages

To support automatic reading of commit messages and modifying the issues
collection alongside you work, TrackDown relies on a [GIT][git] implementation, 
which is capable if executing the script hooks. 

[JGit ][jgit] is lacking this (for the post commit hooks used here) and as a 
result NetBeans and Eclipse cannot use this mimik! With Eclipse you might be 
lucky using the [nightly builds](http://download.eclipse.org/egit/updates-nightly/) 
of JGit (Version 4.6 an up).

Right now TrackDown understands only two commands in the commit messages. 

## refs *id*

Reference the commit in the list of commits at the end of the issue text.

```
git commit -m "refs #MYID - comment" files...
```

This command changes the state to "in progress" from anything like new, nothing,
or even resolved

```
  (Future work: lifts the issue up to the top of the list)
```

## resolves|resolve|fixes *id*

Reference the commit in the list of commits at the end of the issue text.

```
git commit -m "fixes #MYID - comment" files...
```

This command changes the state to "resolved" from anything like new, nothing, or
in progress

```
  (Future work: moves the issue to the top the part of the list where the resolved issues reside)
```


# Command Line Tools

In addition to the init and integration tools, the following commands are 
available:

## Roadmap

Provided that the issues in the issue collection file are marked with version
labels like suggested, the command

```
  trackdown.sh roadmap
```

prints out a complete roadmap of the project sorted by "target versions" in 
[Markdown][markdown] format.

The term "target version" could also be read as "release" or "sprint" or 
anything which describes your development process best.


## List

The command `ls` is used to show all issues marked for a given "target version" 
like in

```
  trackdown.sh ls 1.1
```

where all issues intended to be completed in "target version" 1.1 are listed.

The term "target version" could also be read as "release" or "sprint" or 
anything which describes your development process best.


## Issues

The command

```
  trackdown.sh issues
```

lists all potential issues in the issue collection. Potential means in this case,
that there may be some false positives if there are additional elements in your
issue collection file, which might be interpreted as issues.

Optionally you can add a path to an issue collection file as a parameter like in

```
  trackdown.sh issues ../wiki/issues.md
```


## My Tickets

The command

```
  trackdown.sh mine
```

lists all issues in the issue collection, which are marked with a

```
*Version 1.0* - Currently assigned to: `me`
```

The `me` placeholder in the case is taken - in that order - from

* the first parameter on the command line
* The `me` entry in the `.trackdown/config` file
* The local user name from the environment variable `$USER`

Optionally you can add a path to an issue collection file as an additional parameter 
like in

```
  trackdown.sh mine ../wiki/issues.md
```

or

```
  trackdown.sh mine UserName ../wiki/issues.md
```


# Configuration

The source repository contains a directory named .trackdown.

This directory contains a file named config. There are some options in this
file, which you might want to change.

Example config file for TrackDown:

```
  autocommit=true
  autopush=false
  location=../wiki/issues.md
  prefix=https://github.com/user/project/commit/
  me=My Name
```

## Auto Commit all Issue Collection Changes

Automatically commits the new change to the trackdown branch. If you didn't
change the default location where your source code repository contains the 
a trackdown branch, you will want to leave the unchanged with the default
value `true`.

In other scenarios you may switch it to `false`.

## Auto Push all Issue Collection Commits

Automatically pushes after each commit to the upstream repository. If you didn't
change the default locations where your source code repository is the upstream 
repository of your issue collection you will want to leave the unchanged
with the default value `true`.

In other scenarios you may switch it to false. E.g. if the issue collection is
part of your project wiki then automatic pushing might lead to remote 
operations, which is not desirable.

## Online commit summary prefix

With some GIT backends it is possible to obtain summary with changes and 
commit message online for every commit. To use this facility place a prefix
in the config file where hash of a commit can be appended to for a valid
link for that commit.

## Username for assignments

To allow to work with the user assignment of tickets, the name as used in the
issue collection file can be added here, so that listing of tickets for the
current user is possible.

The assignment will no automatically added to the ticket if that user uses
a commit message related to a ticket, but just the progress flag will be set.


# Installation

Just copy the files from bin/ to a place on your $PATH for now. Perhaps we will
add something more convenient later.

Of course this way the remaining Windows users are locked out.

A symbolic link `td` to the `trackdown.sh` script is recommended for easier
use.

## Prerequisites

TrackDown relies on a [GIT][git] installation available on the path.

## Compatibility

TrackDown is tested to work with Ubuntu 12.04 and newer. It is expected to work
on similar Linux systems and MacOS systems.

There are no plans to support Windows systems except where Un*x like layers as
cygwin are in use.


# Related Projects

I only came accross relates projects which have certain limitations or are 
unmaintained. In each case the limitations have an extent that kept me from
using these systems except for very small or test projects.

## Fossil SCM

What I liked about fossil is, that it brings the three core elements of development

- Source Code
- Documentation or Notes (Wiki)
- Issues

local to my machine for distributed development or disconnected situations.

You don't have to maintain backups since the remote instances are your backups 
of the source code, wiki, and ticketing state.

It does not have a wiki capable of shared editing with later merging like the
[GIT][git] based wikis of [GitLab][gitlab], [GitHub][github], or 
[Bitbucket][bitbucket].

Also it is not possible to the contents of the wiki outside the [Fossil][fossil] 
context e.g. for a documentation web site, since you cannot export the wikis
raw data. (Yes, [Fossil][fossil] provides means to usr the wiki directly as
a documentation site system, which is similar but not exactly the same.)

The drawback is, that it does all these things by creating a nearly closed shop 
system not open to re-use of these elements and not open to external tooling 
outside the [Fossil][fossil] scripting facility.

Additionally I have to keep the [Fossil][fossil] internal web server running for
each repository I am using, to be able to read the notes and issues for a 
project.

Also there is only poor IDE support for [Fossil][fossil] right now, with the
exception of Support for [Idea](https://plugins.jetbrains.com/plugin/7479) 
and my own small [plug-in for NetBeans](http://chiselapp.com/user/backendzeit/repository/netbeans-fossil-plugin/index)
mirrored [here](https://github.com/mgoellnitz/netbeans-fossil-plugin).

## Bitbucket

[Bitbucket.org][bitbucket] a brilliant tool for Open Source or small projects.  
It has decent VCS solutions, a WIKI which can be used distributed through 
[GIT][git].

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [Bitbucket][bitbucket] 
and use TrackDown with [Bitbucket][bitbucket] as the [GIT][git] based 
storage backend. And this is exactly what TrackDown was designed for.

## GitHub

[GitHub][github] is the most used solution for [GIT][git] powered projects
together with a [GIT][git] based wiki (as opposed to Bitbucket and GitLab
the Wiki is a flat folder) and many other usefull details.

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [GitHub][github] 
and use TrackDown with [GitHub][github] as the [GIT][git] based 
storage backend. And this is exactly what TrackDown was designed for.

## GitLab

[GitLab][gitlab] not only is a good online solution but also is a piece of
installable software (like Bitbucket as the renamed Stash is also...). It's
wiki is also [GIT][git] based wiki and it comes with a wealth of other
integration and usefull tools and details.

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [GitLab][gitlab] 
and use TrackDown with [GitLab][gitlab] as the [GIT][git] based 
storage backend. And this is exactly what TrackDown was designed for.

## Trac

A few years ago a colleague stated that he is running a local VM for each 
project, he is involved with, to take notes, track issues, and maintain source 
code.

Of course this does not imply shared use of the Trac service or disconnected use.

Also while Trac is a brilliant tool, this leaves me with the necessity to 
maintain the locally running instances and take backups of them in addition to 
the project VCS and source code repositories. This is not the case for the 
[GIT][git] based solutions in this list, which have a remote repository as a 
backup wiki and source code.

## MDWiki

Unlike [Blogdown](https://github.com/gernest/blogdown) where you again start
a server - but this time on localhost, [MDWiki][mdwiki] just runs in your
browser to view Markdown files nicely formatted locally.

```
file:///home/me/somewhere/thats/green/repo/wiki.html#!issues.md
file:///home/me/somewhere/thats/green/repo/wiki.html#!roadmap.md
```

The output of Trackdown looks pretty usable in this setup and gives a good
overview of the issues as the roadmap.

When you also use GitLab, GitHub, or Bitbucket Wikis, [MDWiki][mdwiki] has
a different understanding, how links should be interpreted. TO get a fully
compatible local and remote viewing setup for these cases, a patched
version of [MDWiki][mdwiki] [exists on GitHub](https://github.com/mgoellnitz/mdwiki/).

## Unmaintained related Projects

These seem to address similar issues, but are not under active development

 - https://github.com/glogiotatidis/gitissius
 - https://github.com/keredson/distributed-issue-tracker


# Migration

To facilitate the use of TrackDown the option of migrating an existing base
of tickets is of course helpful. The choice, which systems are taken as a
data source for such a migration is driven by personal needs.


## GitHub Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [GitHub][github] issue tracker and
mirror tickets for offline use.

It is not intended for changeing the issues in the issue collection file.

Instead of `trackdown.sh use` issue `trackdown.sh github` to setup the mirror
connection.

```
trackdown.sh gihthub <apitoken> <projectname> <owner>
```

Afterwards anytime you can connect to the [GitHub][github] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```


## GitLab Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [GitLab][gitlab] issue tracker and
mirror tickets for offline use.

It is not intended for changeing the issues in the issue collection file.

Instead of `trackdown.sh use` issue `trackdown.sh gitlab` to setup the mirror
connection.

```
trackdown.sh gitlab <apitoken> <projectname> https://<gitlab.host>/
```

Afterwards anytime you can connect to the [GitLab][gitlab] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```

Additionally - since you now are on your command line and perhaps don't want
to switch windows evey second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote assign 68 XYZ
Assigning XYZ to user 68 
```

You have to provide the issues *real* id - not the short one - and the id of
the user, which is also always exported to the issue collection file to 
facility this.


## Redmine

For historical reasons my [Tangram](https://github.com/mgoellnitz/tangram)
project uses [Redmine][redmine] and customers also use [Redmine][redmine]. So 
there are two scenarios where some interfacing would be helpful.

In addition the roadmap outline of TrackDown is very much inspired from the 
[Redmine][redmine] roadmap page.

### Offline mirror

Since I'm - sad enough - not in the position to tell my enterprise scale
customers which ticketing systems to use, there is still the need to have
the issue descriptions, ticket ID, target versions, affected versions and
even the roadmap available offline.

For an offline mirror without the capability to change the status of tickets,
the following setup workflow is used instead of the steps given above:

Instead of `trackdown.sh use` issue `trackdown.sh redmine` to setup the mirror
connection.

```
trackdown.sh redmine <apikey> <projectname> https://<redmine.host>/
```

Afterwards anytime you can connect to the [Redmine][redmine] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```

Additionally - since you now are on your command line and perhaps don't want
to switch windows evey second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote comment XYZ "Hi there."
Adding comment "Hi there." to XYZ
```

```
trackdown.sh remote assign 68 XYZ
Assigning XYZ to user 68 
```

You have to provide the id of the user - not its name, which is also always 
exported to the issue collection file to  facility this.


### Migration

When you think this information mirrored right now is sufficient to cut the ties,
you can setup the created issues collection and roadmap as the repository
and do a `trackdown.sh use`.

The full migration is not covered by a command yet and setting up mirrored
data in the special TrackDown branch must be accomplished manually.


# Issues

Right now we have three collections/iterations/sprints in this issue list:

- *1.0* This should be accomplished before an 1.0 release.
- *nth* This feature is nice to have but can be left out.
- *oos* This issue is relevant but out of the scope of this project.

## NETBEANS interoperation not working due to missing hook implementation in [JGit][jgit] (in progress)

*oos*

While some IDE integrations rely on the [GIT][git] command line tooling and thus 
work perfectly together with this project, NetBeans decided to use the [JGit][jgit] 
library, which only supports a subsets of the [GIT][git] hooks - and not the 
ones we  use here.

I already helped to add the post-commit hook which is needed by this project
and it now is part of the latest nightly builds. Interoperation with trackdown
could not be tested so far.

## GITHUB offline mirror (in progress)

*nth*

Trackdown should be capable of translating [GitHub][github] JSON exports of 
tickets to the special markdown format given here as a mirror for offline use.

 Martin Goellnitz  / Sun Nov 13 21:19:35 2016 [35a52a9d751029ac5cbc3730ea28a3fc682663ce](https://github.com/mgoellnitz/trackdown/commit/35a52a9d751029ac5cbc3730ea28a3fc682663ce)

    refs #GITHUB mirroring in its first incarnation of yet another mirror type

## GITLAB offline mirror (in progress)

*nth*

Trackdown should be capable of translating [GitLab][gitlab] JSON exports of 
tickets to the special markdown format given here as a mirror for offline use.

 Martin Goellnitz  / Sun Nov 13 19:10:27 2016 [29eb793d1caa2e42c1f120aa31e7ceb27929ca6b](https://github.com/mgoellnitz/trackdown/commit/29eb793d1caa2e42c1f120aa31e7ceb27929ca6b)

    refs #GITLAB mirror in its first incarnation as another mirror type

 Martin Goellnitz  / Sun Nov 13 19:11:43 2016 [d239356055272bdd0af6cad32925bb259785717d](https://github.com/mgoellnitz/trackdown/commit/d239356055272bdd0af6cad32925bb259785717d)

    refs #GITLAB offline testing was still in place

 Martin Goellnitz  / Sun Nov 13 19:29:46 2016 [4940d3cf9d3182d0fe591ea82ea94d0651703ffd](https://github.com/mgoellnitz/trackdown/commit/4940d3cf9d3182d0fe591ea82ea94d0651703ffd)

    refs #GITLAB remote command to assign tickets added

 Martin Goellnitz  / Sun Nov 13 19:52:31 2016 [34e0dcec0c72fc0fafe0887a966e392163d6df44](https://github.com/mgoellnitz/trackdown/commit/34e0dcec0c72fc0fafe0887a966e392163d6df44)

    refs #GITLAB issues exports should at least be usable up to 100 issues

## REDMINE offline mirror (in progress)

*nth*

For how historical reasons I have projects with [Redmine][redmine] ticketing in 
use and with still relevant tickets. Some of them might even be a candidate to 
migrate to Trackdown for others it might be sufficient to get a current offline 
mirror when the repository is not available.

Trackdown should be capable of translating [Redmine][redmine] JSON exports of 
tickets to the special markdown format given here. 

For the mirror scenario, certain 
limitations are acceptable, 

For  migration scenarios the commit lists should be included and even closed 
tickets should be taken into account to not lose the relevant parts of the
project history.

 Martin Goellnitz  / Sun Nov 13 01:22:34 2016 [dcf643bf7b21300561013b6cd5fbf202a0567009](https://github.com/mgoellnitz/trackdown/commit/dcf643bf7b21300561013b6cd5fbf202a0567009)

    refs #REDMINE mirroring started

 Martin Goellnitz  / Sun Nov 13 02:48:36 2016 [7211c3ce7b6f7bed464fa6c866239b5ced3bd4e2](https://github.com/mgoellnitz/trackdown/commit/7211c3ce7b6f7bed464fa6c866239b5ced3bd4e2)

    refs #REDMINE mirror shoud overwrite issue collection and no always append

 Martin Goellnitz  / Sun Nov 13 12:21:00 2016 [a82c03fdf6356ef4079446fe7f3d75cae80124d7](https://github.com/mgoellnitz/trackdown/commit/a82c03fdf6356ef4079446fe7f3d75cae80124d7)

    refs #REDMINE mirror command should be named mirror and the old sync command keep that name

 Martin Goellnitz  / Sun Nov 13 12:55:45 2016 [a745c43eb4a444bae91dc15d2b601f78e63e8722](https://github.com/mgoellnitz/trackdown/commit/a745c43eb4a444bae91dc15d2b601f78e63e8722)

    refs #REDMINE mirror now extracts more details from the original tickets

## ASSIGNMENT of issues should be part of the format and tooling (in progress)

*1.0*

We need a facility to deal with assignments of tickets to illustrate, who
is currently working on an issue at least as an optional part of the format.

Additionally some support in the tooling is needed to list issues assigned
to the current user


 Martin Goellnitz  / Sun Nov 13 14:47:12 2016 [0aaf357d1474a3877db9da977b9aadba7d9ed6a5](https://github.com/mgoellnitz/trackdown/commit/0aaf357d1474a3877db9da977b9aadba7d9ed6a5)

    refs #ASSIGNMENT of issues to me now listable

## COPY release notes.

*1.0*

When closing a release or sprint, it should be possible to copy all the resolved
issues to a new [Markdown][markdown] file to remove them from the issue 
collection and have a contribution to release notes.

 Martin Goellnitz  / Sun Nov 13 01:51:12 2016 [de3417d6789e59219d8d9616d5498c857f33cb32](https://github.com/mgoellnitz/trackdown/commit/de3417d6789e59219d8d9616d5498c857f33cb32)

    refs #REDMINE mirror users don't have to use git for this purpose - smarter .gitignore handling alongside

## ROADMAP should show percentage for issues already started (resolved)

*1.0*

As with the number of resolved issues there should be a second value for
the work in progress.

 Martin Goellnitz  / Tue Nov 8 20:03:51 2016 [2535f73db2aca2049a018f5b705e2604dc98f28b](https://github.com/mgoellnitz/trackdown/commit/2535f73db2aca2049a018f5b705e2604dc98f28b)

    refs #ROADMAP output enhancement

 Martin Goellnitz  / Wed Nov 9 00:55:22 2016 [0bd7768acc26577da36ae808e21d72deb70452e7](https://github.com/mgoellnitz/trackdown/commit/0bd7768acc26577da36ae808e21d72deb70452e7)

    resolve #ROADMAP enhancements

## SETUP tracking repository symmetrically (resolved)

*1.0*

The local tracking branch with its special checkout should be setup symmetrically
to ther root repository checkout with simple push style and user and email
set up locally.

 Martin Goellnitz  / Wed Nov 9 01:42:57 2016 [674b85ec7bebbf36618b000098c9195893fc3f90](https://github.com/mgoellnitz/trackdown/commit/674b85ec7bebbf36618b000098c9195893fc3f90)

    resolve #SETUP tracking repository symmetrically

## SYNCHRONIZE roadmap also on unhandled commits (resolved)

*1.0*

The roadmap file should be updated on every commit since there might be
changes in the issue collection file not produced by the commit hook script
which might affect the roadmap.

 Martin Goellnitz  / Wed Nov 9 01:26:57 2016 [b5187ae2af3e8718fc943ccc21bbe1fd91458174](https://github.com/mgoellnitz/trackdown/commit/b5187ae2af3e8718fc943ccc21bbe1fd91458174)

    refs #SYNCHRONIZE roapmap on every commit

 Martin Goellnitz  / Wed Nov 9 01:32:00 2016 [4802cb811866529bcb52b100693219a206fa1e43](https://github.com/mgoellnitz/trackdown/commit/4802cb811866529bcb52b100693219a206fa1e43)

    resolve #SYNCHRONIZE roadmap also on otherwise unhandled commits

## ROOT directory of the source code must be a valid roadmap and issue file location (resolved)

*1.0*

Due to forced set of symbolic links in the root directory of the source code
respository to the roadmap and issue collection file, the 'use' step fails.

 Martin Goellnitz  /    Tue Sep 6 21:29:12 2016 +0200

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
and other information. Provide configuration options for trackdown to extend
the commit hashes to full URLs when adding a commit note to the issues 
collection file resulting in callable HTTP-links.

 Martin Goellnitz  / Tue Nov 8 19:22:15 2016  (commit 7931fbc6a6379032e19733af3f343261989c1108)

    refs #PREFIX commit hashes to form clickable URLs

 Martin Goellnitz  / Tue Nov 8 19:43:10 2016 [0d0f42e3606654c2b036113e411ee313ce4f9493](https://github.com/mgoellnitz/trackdown/commit/0d0f42e3606654c2b036113e411ee313ce4f9493)

    resolve #PREFIX commit hashes to form clickable links

## MULTIISSUE There can be only one issue per commit.

*nth*

Right now we only support the extraction of one issues ID per [GIT][git] commit.

[markdown]: https://daringfireball.net/projects/markdown/
[git]: http://git-scm.com/
[trac]: http://trac.edgewall.org/
[bitbucket]: https://bitbucket.org/
[fossil]: http://fossil-scm.org/index.html/doc/trunk/www/index.wiki
[gitlab]: https://gitlab.com/
[github]: https://github.com/
[jgit]: https://eclipse.org/jgit/
[redmine]: http://www.redmine.org/
[mdwiki]: http://mdwiki.info
