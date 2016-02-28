# TrackDown

[![License](https://img.shields.io/github/license/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/blob/master/LICENSE)

Issue Tracking with plain [Markdown][markdown].

In short: You are missing the "git clone" for your tickets from [github.com][github]
or [bitbucket.org][bitbucket] where we already have this for code and wiki?

You need issue tracking which works for distributed and potentially disconnected
situations together with your distributed version control [GIT][git] and e.g. your
also distributed wiki editing through [GIT][git] as well?

Then this here is for you!

It is not intended for large, permanently online or connected teams and heavy flows
of tickets though, since you will be having only one file a plain [Markdown][markdown]
with your issues - and optionally other stuff - collected in it.


# Design

While TrackDown does not define an issue related workflow, it has some intended workflow
elements which are supported:

The issues are defined and maintained in a single [Markdown][markdown] file following
the format given here.

The commit hook of TrackDown reads the commit messages and modifies that issue collection
if your commit messages relate to some of the issues.

Additionally a roadmap file is automatically maintained for your tickets.

The issue collection this way is held local on your machine and not remote in the
database of a tracking system. (Which is something also [Fossil][fossil] supports.)
Like with the source code, it is pushed to remote repositories if needed (or possible).
The simple [Markdown][markdown] format and the usage of [GIT][git] as a backend
support distributed, shared editing and later merging of the issues and the related
notes in the issue collection. (This is where the parallel with [Fossil][fossil]
ends).


# The Format

While sticking to only partly structured [Markdown][markdown] the following elements
should be maintainable with TrackDown:

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

  The headline commits at level three is optional. The commit messages are inserted
  just as the last part of the issue's level two text area.
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

There are two ways to setup TrackDown. The default way is to use it in a
separate branch of you source code repository and have it editable in your IDE
through a symbolic link to the issue collection file which is maintained by you
through direct typing or the commit hook integration.

The second way is to use the file at a different location - e.g. in the wiki of
the project instead of the source code repository, which is described later.

## Initialize the Repository

If you want to track the issues in a trackdown branch of your source code repository
and not in any other location of your chosing, you need to modify the [GIT][git]
repository accordingly. You source code repository must contain at least one commit
for this to work. To initialize a [GIT][git] repository that way, call the script

```
  trackdown.sh init
```

This creates the TrackDown thread for the issue tracking. You have to manually
propagate this thread to your upstream repositories. TrackDown does not
interfere with your remote workflow.

```
  git push original trackdown
```

Initialization must only to be executed once for a repository and all of its
fork and clones.

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

Right now TrackDown understands only two commands in the commit messages. It relies
on a git implementation which is capable if executing the script hooks. JGit
is lacking this (for the post commit hooks used here) and as a result NetBeans and
Eclipse cannot use this mimik.

## refs *id*

Reference the commit in the list of commits at the end of the issue text.

This command changes the state to "in progress" from anything like new, nothing,
or even resolved

```
  (Future work: lifts the issue up to the top of the list)
```

## resolves|fixes *id*

Reference the commit in the list of commits at the end of the issue text.

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
file, which you can change.

Example config file for TrackDown:

```
  autocommit=true
  autopush=false
  location=../wiki/issues.md
```


```
  (Future Work: It also contains a file named trackdown.sh update for TrackDown updates)
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


# Installation

Just copy the files from bin/ to a place on your $PATH for now. Perhaps we will
add something more convenient later.

Of course this way the remaining Windows users are locked out.


# Issues

Right now we have three collections/iterations/sprints in this issue list:

- *1.0* This should be accomplished before an 1.0 release.
- *nth* This feature is nice to have but can be left out.
- *oos* This issue is relevant but out of the scope of this project.

## Doesn't interoperate with NetBeans

*oos*

While some IDE integrations rely on the git command line tooling and thus work
perfectly together with this project, NetBeans decided to use the

## COPY release notes.

*1.0*

When closing a release or sprint, it should be possible to copy all the resolved
issues to a new [Markdown][markdown] file to remove the from the issue collection
and have a contribution to release notes.

## MULTIISSUE There can be only one issue per commit.

*nth*

Right now we only support the extraction of one issues ID per git commit.

[markdown]: https://daringfireball.net/projects/markdown/
[git]: http://git-scm.com/
[trac]: http://trac.edgewall.org/
[bitbucket]: https://bitbucket.org/
[fossil]: http://fossil-scm.org/index.html/doc/trunk/www/index.wiki
[github]: https://github.com/
