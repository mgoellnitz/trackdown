# TrackDown

[![Latest Release](https://img.shields.io/github/release/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/releases/latest)
[![License](https://img.shields.io/github/license/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/blob/master/LICENSE)

Issue Tracking with plain [Markdown][markdown].

In short: You are missing the "git clone" for your tickets from [github.com][github]
or [bitbucket.org][bitbucket] where we already have this for code and wiki?

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

The commit hook of TrackDown reads the commit messages and modifies that issue 
collection if your commit messages relate to some of the issues.

Additionally a roadmap file is automatically maintained for your tickets.

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

  *Target Version (optional)*

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

The first - default - way is to use it in a separate branch of you source code 
repository and have it editable in your IDE through a symbolic link to the issue 
collection file which is maintained by you through direct typing or the commit 
hook integration.

The second way is to use the file at a different location - e.g. in the wiki of
the project instead of the source code repository, which is described later.

## Initialize the Repository

If you want to track the issues in a trackdown branch of your source code 
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

Right now TrackDown understands only two commands in the commit messages. It 
relies on a [GIT][git] implementation which is capable if executing the script 
hooks. 

[JGit ][jgit] is lacking this (for the post commit hooks used here) and as a 
result NetBeans and Eclipse cannot use this mimik!

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

## resolves|fixes *id*

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

In addition to the init and integration tools the following commands are available

## Roadmap

The command

```
  trackdown.sh roadmap
```

prints out a complete roadmap of the project if you entered "target version"s for
you issues sorted by "target versions" in [Markdown][markdown] format.

The term "target version" could also be read as "release" or "sprint" or anything
which describes your development process best.


## List

The command `ls` is used to show all issues from a given "target version" like in

```
  trackdown.sh ls 1.1
```

where all issues intended to be completed in "target version" 1.1 are listed.

The term "target version" could also be read as "release" or "sprint" or anything
which describes your development process best.


## Issues

The command

```
  trackdown.sh issues
```

list all potential issues in the issue collection. Potential means in this case,
that there may be some false positives if you not only collect issues with this
tool.

Optionally you can add a path to an issue collection file as a parameter like in

```
  trackdown.sh use ../wiki/issues.md
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
  prefix=https://github.com/mgoellnitz/tangram/commit/
```

## Auto Commit all Issue Collection Changes

Automatically commits the new change to the trackdown branch. If you didn't
change the default location where your normal source code repository contains
the trackdown branch will want to leave the unchanged to true.

In other scenarios you may switch it to false.

## Auto Push all Issue Collection Commits

Automatically pushes after each commit to the upstream repository. If you didn't
changethe default locations where your normal source code repository is the
upstream repository of your issue collection you will want to leave the unchanged
to *true*.

In other scenarios you may switch it to false. E.g. if the issue collection is
part of your project wiki then automatically pushing might lead to remote
operations which is not desirable.

## Online commit summary prefix

With some GIT backends it is possible to obtain summary with changes and 
commit message online for every commit. Tu use this facility place a prefix
in the config file where hash of a commit can be appended to for a valid
link for that commit.


# Installation

Just copy the files from bin/ to a place on your $PATH for now. Perhaps we will
add something more convenient later.

Of course this way the remaining Windows users are locked out.

## Prerequisites

TrackDown relies on a [GIT][git] installation available on the path.

## Compatibility

TrackDown ist tested to work on Ubuntu 12.04 and newer. It is expected to work
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
if the source code, wiki and ticketing state.

It does not have a wiki capable of shared editing with later merging like the
[GIT][git] based wikis of [github.com][github] or [bitbucket.org][bitbucket].

Also it is not possible to the contents of the wiki outside the [Fossil][fossil] 
context e.g. for a documentation web site, since you cannot export the wikis
raw data. (Yes, [Fossil][fossil] provides means to usr the wiki directly as
a documentation site system, which is similar but not exactly the same.)

The drawback is, that it does all these things  by creating a nearly closed shop 
system not open to re-use of these elements and not open to external tooling 
outside the [Fossil][fossil] scripting facility.

Additionally I have to keep the [Fossil][fossil] internal web server running for
each repository I am using, to be able to read the notes and issues for a project.

## bitbucket.org

[Bitbucket.org][bitbucket] a brilliant tool for Open Source or small projects.  
It has decent VCS solutions, a WIKI which can be used distributed through 
[GIT][git].

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [bitbucket.org][bitbucket] 
and use TrackDown with [bitbucket.org][bitbucket] as the [GIT][git] based 
storage backend.

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

## Unmaintained related Projects

 - https://github.com/glogiotatidis/gitissius

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

## ROADMAP should show percentage for issues already started (in progress)

*1.0*

As with the number of resolved issues there should be a second value for
the work in progress.

 Martin Goellnitz  / Tue Nov 8 20:03:51 2016 [2535f73db2aca2049a018f5b705e2604dc98f28b](https://github.com/mgoellnitz/trackdown/commit/2535f73db2aca2049a018f5b705e2604dc98f28b)

    refs #ROADMAP output enhancement

## SETUP tracking repository symmetrically (in progress)

*1.0*

The local tracking branch with its special checkout should be setup symmetrically
to ther root repository checkout with simple push style and user and email
set up locally.

## SYNCHRONIZE roadmap also on unhandled commits

*1.0*

The roadmap file should be updated on every commit since there might be
changes in the issues collection file not produced by the commit hook script
which might affect the roadmap.

## ROOT directory of the source code must be a valid roadmap and issue file location (in progress)

*1.0*

Due to forced set of symbolic links in the root directory of the source code
respository to the roadmap and issue collection file, the 'use' step fails.

 Martin Goellnitz  /    Tue Sep 6 21:29:12 2016 +0200

    refs #ROOT - make root directory of source code a valid place for the issue collection file and roadmap file

## COPY release notes.

*1.0*

When closing a release or sprint, it should be possible to copy all the resolved
issues to a new [Markdown][markdown] file to remove them from the issue 
collection and have a contribution to release notes.

## UPDATE command for the commit hook (resolved)

*1.0*

Add an update command so that the commit hook can be updated alongside the
tool script to be in sync.

## HASH of the commit should be part of the listing (resolved)

*1.0*

When adding a commit note to the issues collection file, the hash of that
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
[github]: https://github.com/
[jgit]: https://eclipse.org/jgit/
