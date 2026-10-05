# Source notes

## Feldman, Kamath, and Srebro

The manuscript cites *Invited Open Problem: Is the Power of Deep Learning over Linear Models Inherently Distribution Dependent?*, COLT 2026, PMLR 336:7117–7122. The two passages below were supplied by the author for the original revision. The proof-flaw passage and its attribution were checked against the publisher's PDF for v2 on 4 October 2026.

On the scope of the network question:

> Instead of formally defining 'benign' or 'natural' networks, we state the open problem in terms of the simplest architecture. However, the question is relevant and interesting for any 'benign' architecture that avoids such 'cheating'.

On the Karchmer–Malach claims:

> claimed upper bounds do not hold due to a flaw in the proof (Karchmer and Malach, 2026).

Section 5.1 ends the quotation at "proof" and states that Feldman, Kamath, and Srebro cite a personal communication from Karchmer and Malach. Their bibliography identifies that communication as 2026; it is not a separate published paper. The incidence family is presented as an explicit counterexample to Karchmer and Malach's intermediate Theorem 4.1, consistent with the reported flaw. This does not infer that the conclusion of their mini-batch SGD Theorem 3.3 is false. The paper does not introduce a definition of benign networks or a new gradient-descent result.

## Independence and prior work

The authored version includes the exact independence statement requested by the author. The draft-sharing date is author-provided history, not a quotation from private correspondence. The anonymous review version retains the independence claim and suppresses the identifying history.

Patel is cited as arXiv:2609.19780v1, first submitted September 17, 2026. The arXiv submission history was checked directly for v2: v1 is dated 17 September 2026, 06:49:33 UTC (https://arxiv.org/abs/2609.19780). The quantitative comparison uses the unpadded read-once-DNF parameters. The qualitative separation from Diakonikolas–Kane–Ren and Razborov–Sherstov is credited in one neutral sentence, as Patel makes explicit.

The Karchmer–Malach bibliography entry links to the published ICML paper at https://proceedings.mlr.press/v267/karchmer25a.html and retains the note that theorem numbering refers to arXiv:2505.10423v1. Their Definition 3.2 places the universal marginal quantifier inside the good-target event; Definition 3.5 uses one-sided pairwise correlations. These are the conventions used in the comparison. Their literal unthresholded 0–1 loss is no smaller than the Boolean threshold loss used for the lower bound here.

The incidence construction, its large-rectangle property, and the minimax rectangle device are credited to Hatami, Hatami, Pires, Tao, and Zhao, ECCC TR22-079 (2022). The polynomial sign-pattern ingredient is credited to Warren, with Alon–Moran–Yehudayoff as the sign-rank reference.

## Expository references

The revision used the online COLT papers of Alon, Moran, and Yehudayoff (2016), Feldman (2017), and Kamath, Montasser, and Srebro (2020) as models for motivation, theorem transitions, and proof organization. This is not a claim about award status. No sentences from their exposition were copied.
