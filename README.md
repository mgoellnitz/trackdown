# TrackDown

[![Latest Release](https://img.shields.io/github/release/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/releases/latest)
[![License](https://img.shields.io/github/license/mgoellnitz/trackdown.svg)](https://github.com/mgoellnitz/trackdown/blob/master/LICENSE)
[![Build](https://img.shields.io/gitlab/pipeline/mgoellnitz/trackdown.svg)](https://gitlab.com/mgoellnitz/trackdown/pipelines)

Issue Tracking with plain [Markdown][markdown] for [GIT][git] and 
[Mercurial][hg].

In short: You are missing the `git clone` or `hg clone` respectively for your 
tickets from [GitLab][gitlab], [GitHub][github], [Bitbucket][bitbucket], or some
other services (see below) where we already have this for code and wiki?

You need issue tracking which works for distributed and potentially disconnected
situations together with your distributed version control [GIT][git] or
[Mercurial][hg] and e.g. also your distributed wiki editing through [GIT][git] 
or [Mercurial][hg] as well?

Then this here is for you!

It is not intended for large, permanently online or connected teams and heavy 
flows of tickets though, since you will be having only one file with plain 
[Markdown][markdown] with your issues - and optionally other stuff - collected 
in it.

The currently open issues of TrackDown itself can be found
[here](https://github.com/mgoellnitz/trackdown/blob/trackdown/issues.md) and
[here](https://gitlab.com/mgoellnitz/trackdown/blob/trackdown/issues.md).

The corresponding roadmap is placed 
[here](https://github.com/mgoellnitz/trackdown/blob/trackdown/roadmap.md) and
[here](https://gitlab.com/mgoellnitz/trackdown/blob/trackdown/roadmap.md).

# Design

While TrackDown does not define an issue related workflow, it has some intended 
workflow elements which are supported:

The issues are defined and maintained in a single [Markdown][markdown] file 
following the format given here.

The [GIT][git] post-commit hook or [Mercurial][hg] commit hook of TrackDown 
reads the commit messages and  modifies that issue collection if your commit 
messages relate to some of the  issues.

Additionally a roadmap file is automatically maintained for your tickets.
This roadmap file groups the issue's headlines in groups according to their
version label and illustrated progress counting issues in progress and resolved
issues.

The issue collection this way is held local on your machine and not remote in 
the database of a tracking system. (Which is something also [Fossil][fossil] 
supports.) Like with the source code, it is pushed to remote repositories if 
needed (or possible). The simple [Markdown][markdown] format and the usage of 
[GIT][git] or [Mercurial][hg] as a backend support distributed, shared editing 
and later merging of the issues and the related notes in the issue collection. 
(This is where the  parallel with [Fossil][fossil] ends).


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

Only digits, letters and dots. No spaces allowed.

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
automatically via commits to your sourcecode through the (post-)commit hook of
TrackDown.

The second way is to use the file at a different location - e.g. in the wiki of
the project instead of the source code repository, which is described later.

In both cases the automatically maintained roadmap file resides next to the
issue collection file.


## Initialize the Repository

If you want to track the issues in a TrackDown branch of your source code 
repository and not in any other location of your chosing, you need to modify the 
[GIT][git] or [Mercurial][hg] repository accordingly. Your source code 
repository must contain at least one commit for this to work. 

To initialize your source code repository this way, call the script

```
trackdown.sh init
```

This creates the TrackDown branch for the issue tracking. For [GIT][git] 
respositories, you have to manually propagate this thread to your upstream 
repositories. 

```
git push origin trackdown
```

TrackDown does not interfere with your remote workflow for any version control
system: Also for [Mercurial][hg] the trackdown branch will only show up in the 
remote repositories if you push it.

```
hg push
```

Initialization must only be executed once for a repository including all of its 
forks and clones.

If you want to use the issue collection file from a different location than the
special TrackDown branch, leave out this step.


## Repository Integration

Regardless of the location of the issue collection file, for each clone of the
repository you have to set up the TrackDown tooling to be able to use it
integrated with your source code commits.

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
Automatic commit and push (see below) will be switched off in the latter case.

This creates (git or hg ignored) links `issues.md` and `roadmap.md` in the root 
directory of your project pointing to the issue collection file and the roadmap.
Additionally it will configure a post-commit hook for [GIT][git] or a commit 
hook for [Mercurial][hg] respectively.

After this step you can edit the issue collection file following the format
mentioned above.


# Commands in the Commit Messages

TrackDown is supposed to read the commit messages when not used as a plain 
mirror and interpret the contents as potential commands for the modification of
alongside you work. 

When using [GIT][git], TrackDown relies on an implementation, which is capable 
of executing the script hooks, which is - as opposed to [Mercurial][hg] - not
the case for all implementations.

[JGit ][jgit] is lacking this (for the post commit hooks used here), and as a 
result NetBeans and Eclipse cannot use this mimik! With Eclipse you might be 
lucky using the [nightly builds](http://download.eclipse.org/egit/updates-nightly/) 
of JGit (Version 4.6 an up).

Right now TrackDown understands only two commands in the commit messages. 


## refs #*id*[,*id*...]

Reference the commit in the list of commits at the end of the issue text.

```
git commit -m "refs #MYID - comment" files...
```

This command changes the state to "in progress" from anything like new, nothing,
or even resolved. If the commit relates to more than one issue, the issues can 
be separated by commas.

```
git commit -m "fixes #ONEID,ANOTHERID - comment" files...
```

```
(Future work: lifts the issue up to the top of the list)
```


## resolves|resolve|fixes #*id*[,*id*...]

Reference the commit in the list of commits at the end of the issue text.

```
git commit -m "fixes #MYID - comment" files...
```

This command changes the state to "resolved" from anything like new, nothing, or
in progress. If the commit relates to more than one issue, the issues can be
separated by commas.

```
git commit -m "fixes #ONEID,ANOTHERID - comment" files...
```

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


## Show Issue Collection Changes Status

To show the current state of the local editing of the issue collection and
roadmap file, even if they reside in a special TrackDown branch and are only
used as symbolic links in the source code repository, a shortcut command is
available, giving a brief summary of the Mercurial or GIT state if the
issue collection and roadmap file.

```
trackdown.sh status
```


## Quick Sync of Issue Collection and Roadmap

Most times the editing changelog of the issue collection file and roadmap file
don't present too much additional information for which is already held in
the commit messages of the source code and the issue collection file itself.

In such situations you can use the shortcut command `sync` to bring the
issue collection and roadmap file on your machine and the remote repository
in sync.

```
trackdown.sh sync
```


## Copy Milestone/Release Contents

The comman `copy` is used to extract the issues related to a given milestone,
release, version, or whatever your terinology might be to a separate file
named after the given parameter. So

```
trackdown.sh copy 1.1
```

copies all notes for the issues marked with "1.1" as a version marker to a
separate file 1.1.md to obtain release notes and get the resolved issues from
the base issue collection file for your current work.


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

It TrackDown discovers common GIT services it tries to automatically discover
the correct prefix für URLs pointing to single commits.


## Username for assignments

To allow to work with the user assignment of tickets, the name as used in the
issue collection file can be added here, so that listing of tickets for the
current user is possible.

The assignment will no automatically added to the ticket if that user uses
a commit message related to a ticket, but just the progress flag will be set.


# Installation

Just copy the files from bin/ to a place on your $PATH for now. Perhaps we will
add something more convenient later. For some functions - especially in the
area of issue tracker mirror - [jq][jq] needs to be installed.

Of course this way the remaining Windows users are locked out.

A symbolic link `td` to the `trackdown.sh` script is recommended for easier
use.


## Prerequisites

TrackDown relies on a [GIT][git] or [Mercurial][hg] installation available on 
the path when used with distributed version control as the backend. The 
mirror feature in turn heavily relies in an installation of [jq][jq] available
through your path.


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
[GIT][git] or [Mercurial][hg], since this backend together with TrackDown can
be used in any scenario with both VCS solutions.

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [Bitbucket][bitbucket] 
and use TrackDown with [Bitbucket][bitbucket] as the [GIT][git] or 
[Mercurial][hg] based storage backend. And this is exactly what TrackDown was 
designed for. For migration purposes or if the limited issue tracking within
bitbucket.org is sufficient, the mirroring feature might come in handy.

Atlassian themselves recommends using Jira.


## GitHub

[GitHub][github] is the obvious solution used in so many [GIT][git] powered 
projects together with a [GIT][git] based wiki (as opposed to [Bitbucket][bitbucket] 
and  [GitLab][gitlab] the Wiki is a flat folder - be warned) and many other 
usefull details.

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [GitHub][github] 
and use TrackDown with [GitHub][github] as the [GIT][git] based 
storage backend. And this is exactly what TrackDown was designed for.

As an alternative you can at least mirror the issues from [GitHub][github] to
have the notes with you and now the issue IDs for offline code commits. Or you
can use the mirroring steps for migration purposes.


## GitLab

[GitLab][gitlab] not only is a good online solution but also is a piece of
on premises software (like Bitbucket for the renamed git-Part - not hg.). It's
wiki is also [GIT][git] based wiki and it comes with a wealth of other
integration and usefull tools and details.

The only thing I'm missing is the distributed offline work for ticketing.

So in this case it is possible to leave out the ticketing of [GitLab][gitlab] 
and use TrackDown with [GitLab][gitlab] as the [GIT][git] based 
storage backend. And this is exactly what TrackDown was designed for.

As an alternative you can at least mirror the issues from [GitLab][gitlab] to
have the notes with you and now the issue IDs for offline code commits.


## Gitea and Gogs

Intended for on premises use as a [GIT][git] based solution for Code and Wiki
together with an issue tracking section, it is also available in some public
online incarnations like [CodeBerg](codeberg) and [Pikacode](pikacode).

Of course [Gitea](gitea) can be used as a TrackDownstorage backend or mirroring
source.

We also expect the related [Gogs](gogs) project to be still usable in the
same way.


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


## Other VCS Services

A small list of tested backends for TrackDown which don't support any kind of
issue tracking but Code and Wiki with the VCS:

* [Helix Team Hub][hth]
* [Visual Studio Services][vss]


## MDWiki

Unlike [Blogdown](https://github.com/gernest/blogdown) where you again start
a server - but this time on localhost, [MDWiki][mdwiki] just runs in your
browser to view Markdown files nicely formatted locally.

```
file:///home/me/somewhere/thats/green/repo/wiki.html#!issues.md
file:///home/me/somewhere/thats/green/repo/wiki.html#!roadmap.md
```

The output of TrackDown looks pretty usable in this setup and gives a good
overview of the issues as the roadmap.

When you also use GitLab, GitHub, or Bitbucket Wikis, [MDWiki][mdwiki] has
a different understanding, how links should be interpreted. To get a fully
compatible local and remote viewing setup for these cases, a patched
version of [MDWiki][mdwiki] [exists on GitHub](https://github.com/mgoellnitz/mdwiki/).


## Unmaintained related Projects

These seem to address similar issues, but are not under active development

 - https://github.com/glogiotatidis/gitissius
 - https://github.com/keredson/distributed-issue-tracker


# Migration and Offline Mirroring

To facilitate the use of TrackDown, the option of migrating an existing base
of tickets is of course helpful. The choice, which systems are taken as a
data source for such a migration is driven by personal needs.


## GitHub Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [GitHub][github] issue tracker and
mirror tickets for offline use.

The mirror - of course - is not intended for changeing the issues in the issue 
collection file. State changes will most likely be triggered on [GitHub][github] 
by your commit messages or manually, after which a call of the mirroring script
can be helpfull.

Instead of `trackdown.sh use` issue `trackdown.sh github` to setup the mirror
connection.

```
trackdown.sh github <projectname> <owner> <apitoken>
```

Afterwards anytime you can connect to the [GitHub][github] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```

Additionally - since you now are on your command line and perhaps don't want
to switch windows every second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote assign 68 XYZ
Assigning 68 to user XYZ
```

You have to provide the issue id and the id of the user, which is also always 
exported to the issue collection file to facilitate this.

Right now there is only the `assign` remote command available.


## GitLab Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [GitLab][gitlab] issue tracker and
mirror tickets for offline use.

The mirror - of course - is not intended for changeing the issues in the issue 
collection file. State changes will most likely be triggered on [GitLab][gitlab] 
by your commit messages or manually, after which a call of the mirroring script
can be helpfull.

Instead of `trackdown.sh use` issue `trackdown.sh gitlab` to setup the mirror
connection.

```
trackdown.sh gitlab <apitoken> <projectname> [https://<gitlab.host>]
```

If you ommit the url prefix, `https://gitlab.com` is used. The project name must
be given without any group or user addition.

Afterwards anytime you can connect to the [GitLab][gitlab] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```

Additionally - since you now are on your command line and perhaps don't want
to switch windows every second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote assign 68 XYZ
Assigning 68 to user XYZ
```

You have to provide the issues *real* id - not the short one - and the id of
the user, which is also always exported to the issue collection file to 
facilitate this.

The commands available are 

* `assign` to assign issues to users
* `milestone` to put issues into milestones
* `comment` to comment issues
* `issue` to create new issues


## Gitea Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [Gitea][gitea] issue tracker and mirror 
tickets for offline use. 

Setup parameters default to values from the [Git][git] repository your current
local directory points to.

The mirror - of course - is not intended for changeing the issues in the issue 
collection file. State changes will most likely be triggered on the [Gitea][gitea]
instance in use by your commit messages or manually, after which a call of the 
mirroring script can be helpfull.

Instead of `trackdown.sh use` issue `trackdown.sh gitea` to setup the mirror
connection.

```
trackdown.sh gitea <apitoken> <projectname> [https://<gitea.host>]
```

If you ommit the url prefix and no values can be derived from your current
working directory, `https://codeberg.org` is used.

Afterwards anytime you can connect to the [Gitea][gitea] system, collect the 
current mirror state to you local issue collection file and the roadmap.

```
trackdown.sh mirror
```

Additionally - since you now are on your command line and perhaps don't want
to switch windows every second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote assign 68 XYZ
Assigning 68 to user XYZ
```

You have to provide the issue id and the id of the user, which is also always 
exported to the issue collection file to facilitate this.

The commands available are 

* `assign` to assign issues to users
* `comment` to comment issues

It is expected that this also works for [Gogs](gogs) backends as well.


## Bitbucket.org Offline Mirror

For disconnected situations which TrackDown is supposed to support, it is
possible to connect a workspace to its [Bitbucket.org][bitbucket] issue 
tracker and mirror tickets for offline use.

Some of my stalled projects reside therer and I already did an export of the
issue tracker contents, which [Bitbucket.org][bitbucket] support, and now added
the offline mirror capabililties to this tool for smother migration away from
the prorietary issue tracker.

The mirror again is not intended for changeing the issues in the issue 
collection file. State changes will most likely be triggered on 
[Bitbucket.org][bitbucket] by your commit messages or manually, after which a 
call of the mirroring script can be helpfull.

Instead of `trackdown.sh use` issue `trackdown.sh github` to setup the mirror
connection.

```
trackdown.sh bitbucket <projectname> <owner> <app-password>
```

Afterwards anytime you can connect to the [Bitbucket.org][bitbucket] system, 
collect the current mirror state to you local issue collection file and the 
roadmap.

```
trackdown.sh mirror
```

In the case of [Bitbucket.org][bitbucket], the mirror script has to ask for
you password on [Bitbucket.org][bitbucket], if you leave out the app password.
App passwords can be generated in the personal [Bitbucket.org][bitbucket]
settings.

Additionally - since you now are on your command line and perhaps don't want
to switch windows every second - there is a `remote` command to issue commands
on the remote mirroring source system.

```
trackdown.sh remote assign 68 XYZ
Assigning 68 to user XYZ
```


## Redmine

For historical reasons my [Tangram](https://github.com/mgoellnitz/tangram)
project used [Redmine][redmine] some time ago and customers also use 
[Redmine][redmine]. So there are two scenarios where some interfacing would be 
helpful.

In addition the roadmap outline of TrackDown is very much inspired by the 
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
trackdown.sh redmine <apikey> <projectname>[,<projectname>...] https://<redmine.host>/
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
Assigning 68 to user XYZ
```

You have to provide the id of the user - not its name, which is also always 
exported to the issue collection file to facility this.


### Migration

When you think this information mirrored right now is sufficient to cut the ties,
you can setup the created issue collection and roadmap as the repository and do 
a `trackdown.sh use`.

The full migration is not covered by a command yet and setting up the mirrored 
data in the special TrackDown branch or any other locaion of your chosing must 
be accomplished manually. The needed steps include:

*Latest Mirror*

Get the latest mirrored data.

```
trackdown.sh mirror
```

*Remove Mirror Configuration*

```
rm -rf .trackdown
```

*Initialize Trackdown*

Special Branch Flavour:

```
trackdown.sh init
trackdown.sh use
mv old-issues.md .git/trackdown/issues.md # or .hg
roadmap.md .git/trackdown/roadmap.md # or .hg
```

Custom location - e.g. wiki

```
mv old-issues.md ../wiki/issues.md
roadmap.md ../wiki/roadmap.md
trackdown.sh use ../wiki/issues.md
(cd wiki; git add issues.md roadmap.md)  # or hg
```

*Clean Up*

Since the mirroring collects as much data as possible, it might be a good idea
to separate already closed releases or milestones from the currently relevant
issues in the issue collection. Use the copy command to do so:

```
trackdown.sh copy Milestone1
```

And now use the remaining issues as the new collection and add the separated
issues as a chages/changelog part to your documentation.

```
mv ../wiki/Milestone1-issues.md ../wiki/issues.md
(cd ../wiki ; git add Milestone1.md) # or hg
```

Of course this cannot only be done for mirror issue collections and is e.g.
used for trackdown itself like for release 1.0 in
[this](https://github.com/mgoellnitz/trackdown/blob/trackdown/1.0.md) and
[this](https://gitlab.com/mgoellnitz/trackdown/blob/trackdown/1.0.md) file.


[markdown]: https://daringfireball.net/projects/markdown/
[git]: http://git-scm.com/
[trac]: http://trac.edgewall.org/
[bitbucket]: https://bitbucket.org/
[fossil]: http://fossil-scm.org/index.html/doc/trunk/www/index.wiki
[gitlab]: https://gitlab.com/
[github]: https://github.com/
[jgit]: https://eclipse.org/jgit/
[redmine]: http://www.redmine.org/
[gogs]: https://gogs.io/
[gitea]: https://gitea.io/
[codeberg]: https://codeberg.org/
[pikacode]: https://v2.pikacode.com/
[mdwiki]: http://mdwiki.info
[jq]: https://stedolan.github.io/jq/
[hg]: https://www.mercurial-scm.org/
[hth]: https://www.perforce.com/products/helix-teamhub
[vss]: https://www.visualstudio.com/team-services/
