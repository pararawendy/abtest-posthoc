# abtest-posthoc
This repository provides a handy R-function that handles end-to-end multiclass AB testing analysis with proportion-based metric (including posthoc test)

## About the function
I wrote a function called ``holistic_abtest``. This function aims to perform all the required statistical tests for a multiclass AB test (i.e. AB test with more than two experimental groups) with proportion-based metric. First, it will perform a Chi-square test on the aggregate data level. If this test is significant, the function will continue to perform a posthoc test that consists of testing each pair of experimental groups to report their adjusted p-values, as well as their absolute lift (difference) confidence intervals.

## Function parameters
The function has four parameters.
1. ``data`` : data to be analyzed, please refer to the following section on the formatting requirement
2. ``method`` : p-value adjustment/correction method, options = {“holm”, “hochberg”, “hommel”, “bonferroni”, “BH”, “BY”, “fdr”, “none”}, default = ``"BH"``
3. ``alpha`` : alpha value, default = ``0.05``
4. ``rounding`` : number of decimal rounding for the adjusted p-values, default = ``10`` 

## Format data
The ``holistic_abtest`` function requires data in ``data.table`` format, with ``dimnames = c("segment", "action")``. Moreover, dimension name ``action`` must consists of two columns ``p`` and ``q``, which together construct proportion-based metric ``p/q``. 

## Reading the output
If the initial Chi-square test on the original data returns a significant result, the function will perform a complete posthoc test and will return a dataframe with five columns.
1. ``pair`` : pair of experimental groups being tested (e.g. ``segment_1 vs segment_2``)
2. ``raw_p_value`` : raw p-value of the corresponding pair
3. ``adj_p_value`` : adjusted p-value of the corresponding pair, significant result is marked with ``*``
4. ``lower_ci`` : lower bound of 95% confidence interval of delta ``segment_2 - segment_1``, note that this column will be NA if the corresponding adjusted p-value is not significant.
5. ``upper_ci`` : upper bound of 95% confidence interval of delta ``segment_2 - segment_1``, note that this column will be NA if the corresponding adjusted p-value is not significant.

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
# define holistic_abtest()

# use the function
holistic_abtest(data)

```
### Results
```
                  pair  raw_p_value   adj_p_value    lower_ci    upper_ci
1  control vs design_a 1.286847e-06  1.9303e-06 * -0.03424870 -0.01444305
2  control vs design_b 1.222260e-07   2.445e-07 *  0.01804483  0.03951195
3  control vs design_c 2.564814e-05 3.07778e-05 *  0.01210044  0.03343750
4 design_a vs design_b 9.910166e-24           0 *  0.04271710  0.06353142
5 design_a vs design_c 2.780364e-19           0 *  0.03677482  0.05745486
6 design_b vs design_c 2.949110e-01  0.2949110465          NA          NA
```
