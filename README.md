# mixdchlet - estimate a mixture Dirichlet prior from counts

![](http://img.shields.io/badge/license-BSD-brightgreen.svg)

The `mixdchlet` program infers a maximum likelihood mixture Dirichlet
distribution to fit a dataset of many observed count vectors
[[Sjolander et al,
1996]](https://doi.org/10.1093/bioinformatics/12.4.327).  Mixture
Dirichlet priors are used in parameter estimation for HMMs, SCFGs, and
other discrete probabilistic models [[Durbin et al.,
1998]](http://eddylab.org/cupbook.html}).  [HMMER](http://hmmer.org)
and [Infernal](http://eddylab.org/infernal) use mixture Dirichlet
priors on residue emission probabilities and transition probabilities.


## Obtain and build from source

The `mixdchlet` code uses our [Easel](http://bioeasel.org) code
library, so start by cloning both repos, with `easel` in the `mixdchlet`
directory:

```
    % git clone https://github.com/cryptogenomicon/mixdchlet
    % cd mixdchlet
    % git clone https://github.com/EddyRivasLab/easel
```

Build Easel separately. It has its own configuration and tests.

```
    % cd easel
    % autoconf
    % ./configure
    % make
    % make check
    % cd ..
```

Then compile the `mixdchlet` program, which only uses a simple
Makefile.  You can edit some things at the top of the Makefile if you
want (like `CC` for your compiler, `CFLAGS` for your compiler flags)
but the defaults are almost certainly fine.

```
    % make
```



## Using mixdchlet

`mixdchlet` has four subcommands. `mixdchlet -h` or just `mixdchlet`
by itself with no options or arguments will print a short help page
that lists them:

  * `mixdchlet fit`:   estimate a new mixture Dirichlet prior
  * `mixdchlet score`: score count data with a mixture Dirichlet
  * `mixdchlet gen`:   generate synthetic count data from a mixture Dirichlet
  * `mixdchlet sample` sample a random mixture Dirichlet

For any of these subcommands, you can get brief help and usage reminder
with a `-h` option, e.g.:
 
```
    % mixdchlet fit -h
```

The most important subcommand is `mixdchlet fit`. You can use
`mixdchlet gen` and `mixdchlet sample` to generate synthetic data and
distributions for testing, and `mixdchlet score` lets you evaluate the
log likelihood of a mixture Dirichlet on a count dataset other than
the training data (for example, a held-out test dataset).

The file `example.pri` is an example of a mixture Dirichlet prior
file. (It's the 9-component prior for amino acid sequence data from
[Sjolander et al,
1996](https://doi.org/10.1093/bioinformatics/12.4.327), and the
default amino acid residue prior for HMMER3.)  The first two fields in
this file are `<K>` and `<Q>`: the alphabet size (20, for amino acid
data), and the number of mixture components (9, here).  Then there are
$Q$ lines, one per mixture component, with $K+1$ fields: a mixture
coefficient $p_q$ (the probability of using this component) followed
by $K$ Dirichlet parameters $\alpha_q(k)$.

You can use this example prior to generate a synthetic count dataset:

```
    % mixdchlet gen -M 100 -N 10000 example.pri > example-10k.ct
```

The `-M 100` option says to sample 100 counts per count vector, and
the `-N 10000` option says to sample 10K count vectors.  The
`example-10k.ct` file contains 10K lines, one per vector; each line
has $K$ fields, the observed counts $c_i(k)$ for residue $k$ in vector
$i$.

Although these are counts, the numbers don't necessarily have to be
integers; you may have used real-valued sequence weights in collecting
estimated counts, for example. Anything after a `#` on a line is
ignored as a comment; blank lines are ignored too.

To train a new mixture Dirichlet:

```
    % mixdchlet fit 9 20 example-10k.ct test.pri
```

This will estimate a mixture Dirichlet with Q=9 components for an
alphabet size of K=20 on the count data in the `example-10k.ct` file,
and save the mixture Dirichlet to the file `test.pri`. (These suffixes
aren't necessary and they can be anything you want; `.ct` and `.pri`
are my own personal conventions.) 

It will also output (to stdout) an arcane data table containing
details from the optimization; you can ignore this table. The one
relevant number to look at is the last line, where it will say
something like "nll = 367413". This is the negative log likelihood of
the fitted mixture Dirichlet. A lower nll is better (e.g. a higher
likelihood fit). You use this objective function value to compare
different models fit to the same dataset.

This inference is computationally intensive. Expect this particular
command to take about 90 sec.  Compute time scales roughly as $NKQ$:
linear in components, alphabet size, and countvectors.  10K count
vectors is a toy amount of data. When we really train a new mixture
Dirichlet, we use on the order of 10M count vectors (from Pfam), so it
takes about 25 cpu-hr.

The maximum likelihood fitting algorithm uses conjugate gradient
descent. (The original Sjolander paper used expectation-maximization;
the log likelihood is differentiable, so gradient descent is a tad
more efficient.) The log likelihood is not convex and the optimization
is local, not global, so different runs will give you different
results. It's advisable to do multiple runs and take the one with the
best (lowest) negative log likelihood, to avoid spurious local optima.







