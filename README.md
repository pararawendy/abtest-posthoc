# abtest-posthoc
This repository provides a handy R-function that handles end-to-end multiclass AB testing analysis with proportion-based metric (including posthoc test)

## About the function
I worte a function called ``hollistic_abtest``. This function aims to perform all the required statistical tests for a multiclass AB test (i.e. AB test with more than two experimental groups) with proportion-based metric. First, it will perform a Chi-square test on the aggregate data level. If this test is significant, the function will continue to perform a posthoc test that consists of testing each pair of experimental groups to report their adjusted p-values, as well as their absolute lift (difference) confidence intervals.

## Function parameters
The function has four parameters.
1. ``data`` : data to be analyzed, please refer to the following section on the formatting requirement
2. ``method`` : p-value adjustment/correction method, options = {“holm”, “hochberg”, “hommel”, “bonferroni”, “BH”, “BY”, “fdr”, “none”}, default = ``"BH"``
3. ``alpha`` : alpha value, default = ``0.05``
4. ``rounding`` : number of decimal rounding for the adjusted p-values, default = ``10`` 

## Format data
The ``hollistic_abtest`` function requires data in ``data.table`` format, with ``dimnames = c("segment", "action")``. Moreover, dimension name ``action`` must consists of two columns ``p`` and ``q``, which together construct proportion-based metric ``p/q``. 

## Reading the output
If the initial Chi-square test on the original data returns a significant result, the function will perform a complete posthoc test and will return a dataframe with five columns.
1. ``pair`` : pair of experimental groups being tested (e.g. ``segment_1 vs segment_2``)
2. ``raw_p_value`` : raw p-value of the corresponding pair
3. ``adj_p_value`` : adjusted p-value of the corresponding pair, significant result is marked with ``*``
4. ``lower_ci`` : lower bound of 95% confidence interval of delta ``segment_2 - segment_1``
5. ``upper_ci`` : upper bound of 95% confidence interval of delta ``segment_2 - segment_1``

## Sample usage
### Codes
```
# prepare data
target = c(8333,8002,8251,8175)
redeemed = c(1062,825,1289,1228)
data = as.table(cbind(redeemed, target))
dimnames(data) = list(segment = c("control","design_a","design_b","design_c"), action = c("redeemed", "target"))

# define the functions
# define posthoc_abtest()
# define hollistic_abtest()

# use the function
hollistic_abtest(data)

```
### Results
```
                  pair  raw_p_value    adj_p_value     lower_ci    upper_ci
1  control vs design_a 1.632451e-05  2.44868e-05 * -0.028509770 -0.01064146
2  control vs design_b 4.564872e-06   9.1297e-06 *  0.012587295  0.03156561
3  control vs design_c 2.545389e-04 0.0003054467 *  0.008103611  0.02701192
4 design_a vs design_b 1.206372e-18            0 *  0.032381756  0.05092238
5 design_a vs design_c 2.732312e-15            0 *  0.027898944  0.04636782
6 design_b vs design_c 3.709578e-01   0.3709577841           NA          NA
```
