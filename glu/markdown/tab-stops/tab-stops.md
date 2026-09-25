---
title: Tab stops
lang: en
css: tab-stops.css
---

# Tab stops

A tab in the text moves on to the next tab stop. The stops come from
the CSS property `-bag-tab-stops`, so the Markdown stays plain text: no
tables, no HTML, just tabs between the columns.

Each tab is written as the entity `&Tab;`, so it shows in the source.
Spaces next to it are dropped, they only make the source easier to
read. A literal tab character works the same, but cannot be told apart
from a space in the editor.

## A contents list

Each line has two tabs: one before the title, one before the page
number. The second stop sits at 100% of the line width and aligns the
number at its end, with a dotted leader across the gap.

::: contents
1 &Tab; Introduction &Tab; 3
2 &Tab; Setting type &Tab; 7
2.1 &Tab; Tab stops &Tab; 12
2.2 &Tab; Leaders across the gap &Tab; 15
3 &Tab; Index &Tab; 121
:::

## Labels and values

A single start stop at 35 mm lines up the values, however long the
labels are.

Name &Tab; Alice Example
Address &Tab; Bob Street 12, 12345 Sample City
E-mail &Tab; alice@example.com
{.form}

## Prices on the decimal comma

Decimal stops line the figures up on their separator, here a comma. A
figure without one, like the column heading, ends at the stop.

Item &Tab; Price per kg &Tab; In stock
Apples &Tab; 3,50 &Tab; 1.234,5
Pears &Tab; 12,75 &Tab; 87
Plums &Tab; 0,9 &Tab; 12.400
{.prices}

## Centered under a line

Two center stops at a quarter and three quarters of the line. The line
starts with a tab, so the first caption is centered on a stop as well.

&Tab; Place, date &Tab; Signature
{.signature}
