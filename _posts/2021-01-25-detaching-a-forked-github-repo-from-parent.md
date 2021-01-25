---
layout: post
title: "detaching a forked github repo from parent"
description: "And how to rewrite history with git rebase"
date: 2021-01-25
tags: [git, rebase, mirror, blog]
---

In the process of developing this blog on Github Pages, I've used and modified a Jekyll theme called Kiko Plus. That theme itself is a fork of the original Kiko theme, which is no longer maintained.

After forking Kiko Plus and making changes, I noticed that my fork still refers to the parent repo on Github. Things like pull requests, issues, etc will still be reflected against the parent repo, so I wanted to make a clean split. I also want to be able to pull request/merge my branches to my own repo instead of the parent.

This technique is called _mirroring_, and Github has documentation for it: [Duplicating a repository](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/duplicating-a-repository)

In addition, it would be nice to clean up all the old commits but keep my newer ones - to do that, I'll _rebase_ and _squash_ the old ones into a single commit.

## Mirror Forked Repo

The first step is to make a local bare clone of the existing Github Pages repo, and `cd` into it:

```bash
$ git clone --bare git@github.com:devedge/devedge.github.io.git && cd devedge.github.io.git
```

Next, create a new temporary repository in Github for the mirror: `new-devedge.github.io`

Push the bare clone up to the new temporary repository:

```bash
$ git push --mirror git@github.com:devedge/new-devedge.github.io.git
```

Delete the forked repository from Github (`devedge.github.io`), and rename the temporary repository to its name (`new-devedge.github.io -> devedge.github.io`)

Now the fork is an independent mirror!

## Rebase Commits

There's a lot of work done in the previous repo that I would like to compress down to one commit. To do this, let's first rebase the entire repo history up to the first commit:

```bash
$ git rebase -i --root master
```

The interactive rebasing tool will open to your preferred terminal editor:

![Interactive Rebase Tool](/assets/images/mirror-repo-rebase.png){: .center-image}

Reword the first commit, and prefix the remaining with `fixup` so they get squashed together without their commit messages.

After saving the changes, the rebase is ready to push. Force the push to ovewrite the remote origin:

```bash
$ git push --force
```

and now the repo history is consolidated.
