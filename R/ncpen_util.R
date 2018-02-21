#' @title
#' Check whether column names are derivation of a same base.
#'
#' @description
#' This is internal use only function.
#'
#' @param base.cols vector of base column names.
#' @param a first column to be compared.
#' @param b second column to be compared.
#'
#' @return
#' TRUE if same base, FALSE otherwise.
#'
same.base = function(base.cols, a, b) {
     if(a==b) return(T);
     if(is.null(base.cols)) return (F);

     for(base in base.cols) {
          index = regexpr(base, c(a, b));
          if(index[1] > 0 & index[1] == index[2]) {
               return (T);
          }
     }

     return (F);
}
# same.base("aa", "aa", "aa20")
# same.base(NULL, "aa", "aa")

#' @title
#' Check whether a pair should be excluded from interactions.
#'
#' @description
#' This is internal use only function.
#'
#' @param excluded.pair a pair.
#' @param a first column to be compared.
#' @param b second column to be compared.
#'
#' @return
#' TRUE if excluded, FALSE otherwise.
#'
excluded = function(excluded.pair, a, b) {
     if(is.null(excluded.pair)) return (F);

     for(pair in excluded.pair) {
          str1 = paste(pair[1], pair[2]);
          if(str1 == paste(a, b) | str1 == paste(b, a)) {
               return (T);
          }
     }

     return (F);
}

# el = list(c("a", "b"), c("d", "c"));
#
# excluded(el, "b", "a")
# excluded(el, "b", "a1")
# excluded(el, "b", "d")
# excluded(el, "d", "c")

# base.cols = c("aa", "bb", "cc", "dd", "ee");
# a = "aa.33"
# b = "bb.44"
#
# c = "cc.44"
# d = "ccdde";
# e = "aabcde"
# same.base(base.cols, e, e)


#' @title
#' Construct Indicator Matrix
#'
#' @description
#' \code{to.indicators} converts a categorical variable into a \code{\link{data.frame}}
#' with indicator (0 or 1) variables for each category.
#'
#' @param vec a categorical vector.
#' @param exclude.base \code{FALSE} means to include all the categories. \code{TRUE}
#' means to exclude one category as a base case.
#'  If \code{base} is not specified, a random category will be removed.
#' @param base a base category removed from the indicator matrix. This option works
#'  only when the \code{type} variable is set to \code{"exclude.base"}.
#' @param prefix a prefix to be used for column names of the output matrix.
#' Default is "cat_" if \code{prefix} is \code{NULL}.
#' For example, if a category vector has values of c("a", "b", "c"),
#' column names of the output matrix will be "cat_aa", "cat_bb" and "cat_cc".
#' If \code{vec} is a \code{\link{data.frame}} and \code{prefix} is \code{NULL},
#' then the \code{vec}'s column name followed by "_" will be used as a prefix.
#'
#' @return
#' This returns an object of \code{\link{matrix}} which contains indicators.
#'
#'
#' @examples
#' a1 = 4:10;
#' b1 = c("aa", "bb", "cc");
#'
#' to.indicators(a1, base = 10);
#' to.indicators(b1, base = "bb", prefix = "T_");
#' to.indicators(as.data.frame(b1), base = "bb");
#'
#'
#'
#' @export
to.indicators = function(vec, exclude.base = TRUE, base = NULL, prefix = NULL) {
     # Test block
     # vec = as.data.frame(b1);
     # exclude.base = T;
     # prefix = "cat_";
     # base = NULL;
     ############################

     if(class(vec) == "data.frame") {
          if(is.null(prefix)) {
               prefix = paste(colnames(vec), "_", sep = "");
          }
     } else {
          if(is.null(prefix)) {
               prefix = "cat_";
          }
          vec = as.data.frame(as.factor(vec));
     }
     colnames(vec) = prefix;

     if(exclude.base == TRUE) {
          if(is.null(base)) {
               return (model.matrix(~ . + 0, data = vec)[,-1]);
          } else {
               ret = model.matrix(~ . + 0, data = vec)[,];
               rm.col = which(colnames(ret)==paste(prefix, base, sep = ""));
               if(length(rm.col) >0) {
                    ret = ret[, -rm.col];
               }

               return (ret);
          }
     } else {
          return (model.matrix(~ . + 0, data = vec)[,]);
     }
}

# a1 = 4:10;
# b1 = c("aa", "bb", "cc");
#
# to.indicators(a1, base = 10);
# to.indicators(b1, base = "bb", prefix = "T_");
# to.indicators(as.data.frame(b1), base = "bb");


#' @title
#' Power Data
#'
#' @description
#' \code{power.data} power data and return a \code{\link{data.frame}} with column names with tail.
#'
#' @param data a \code{\link{data.frame}} or \code{\link{matrix}} object.
#' @param power power.
#' @param tail tail text for column names for powered data. For example, if a column "sales" is powered by 4 (=\code{power})
#' and \code{tail} is "_pow", then the output column name becomes "sales_pow4".
#'
#' @return
#' This returns an object of \code{\link{matrix}}.
#'
#'
#' @examples
#' df = data.frame(a = 1:3, b= 4:6);
#' power.data(df, 2, ".pow");
#'
#'
#' @export
power.data = function(data, power, tail = "_pow") {
     pow.data = data^power;
     colnames(pow.data) = paste(colnames(pow.data), tail, power, sep = "");

     return (pow.data);
}

# df = data.frame(a = 1:3, b= 4:6);
# power.data(df, 2, ".pow");

#temp = power.data(subset(raw.prepay.data, select = c("FICO", "INT_RT")), 2);
#head(temp);

#' @title
#' Construct Interaction Matrix
#'
#' @description
#' \code{interact.data} interacts all the data in a \code{\link{data.frame}} or \code{\link{matrix}}.
#'
#' @param data a \code{\link{data.frame}} or \code{\link{matrix}} to interact.
#' @param base.cols indicates columns from one category.
#' Interactions among variables from a same base.col will be avoided. For example, if three indicator columns,
#' "ChannelR", "ChannelC" and "ChannelB", are created from a categorical column "Channel", then the interaction among them
#' can be excluded by assigning \code{base.cols=c("Channel")}. Multiple \code{base.cols} are possible.
#' @param exclude.pair the pairs will be excluded from interactions. This should be a \code{\link{list}} object of pairs.
#' For example, \code{list(c("a1", "a2"), c("d1", "d2"))}.
#'
#' @return
#' This returns an object of \code{\link{matrix}} which contains interactions.
#'
#'
#' @examples
#' df = data.frame(1:3, 4:6, 7:9, 10:12, 13:15);
#' colnames(df) = c("aa", "bb", "cc", "dd", "aa2");
#' df
#'
#' interact.data(df);
#' interact.data(df, base.cols = "aa");
#' interact.data(df, base.cols = "aa", exclude.pair = list(c("bb", "cc")));
#'
#'
#'
#' @export
interact.data = function(data, base.cols = NULL, exclude.pair = NULL) {
     data.fields = colnames(data);
     #    data = prepay.data;
     # if(is.null(base.cols)) {
     #      base.cols = data.fields;
     # }
     #base.cols = c("a", "b", "c");
     #data.fields = c("a", "b", "c", "d", "a_2", "b_2", "c_2");
     n.fields = length(data.fields);
     # construct formula string
     interact.str = "~";

     for(i in 1:(n.fields-1)) {
          for(j in (i+1):n.fields) {
               lfield = data.fields[i];
               rfield = data.fields[j];
               if(!same.base(base.cols, lfield, rfield)
                  & !excluded(exclude.pair, lfield, rfield)) {
                    interact.str = paste(interact.str, paste(lfield, ":", rfield, sep = ""), "+", sep = " ");

               }
          }
     }

     interact.str = substr(interact.str, 1, nchar(interact.str)-2); # truncate the last "+".
     # print(interact.str);
     return (model.matrix(formula(interact.str), data = as.data.frame(data))[,-1]);
}

# df = data.frame(1:3, 4:6, 7:9, 10:12, 13:15);
# colnames(df) = c("aa", "bb", "cc", "dd", "aa2");
# df
#
# interact.data(df);
# interact.data(df, base.cols = "aa");
# interact.data(df, base.cols = "aa", exclude.pair = list(c("bb", "cc")));
#

# Not made avaialble yet -----------------------------------------------
# step.data = function(vec, by = 0.50) {
#      # "st.min_(min + by) is reference
#      #vec = ncpen.data$int_spread;
#      #by = 0.5
#
#      field.name = names(vec)[1];
#      #field.name = "aa"
#      min.val = min(vec);
#      max.val = max(vec);
#
#      l.bound = min.val + by;
#      u.bound = l.bound + by;
#
#      step.var.str = sprintf("%s.%.2f_%.2f", field.name, l.bound, u.bound);
#      step.var.str= gsub("-", "n", step.var.str); # - sign to n
#
#      ret = as.data.frame(vec);
#      ret[, step.var.str] = 1*(l.bound <= ret[,1] & ret[,1] < u.bound);
#      #head(ret);
#      while(T) {
#           l.bound = u.bound;
#           if(l.bound > max.val) {
#                break;
#           }
#           u.bound = l.bound+by;
#
#           step.var.str = sprintf("%s.%.2f_%.2f", field.name, l.bound, u.bound);
#           step.var.str= gsub("-", "n", step.var.str); # - sign to n
#           ret[, step.var.str] = 1*(l.bound <= ret[,1] & ret[,1] < u.bound);
#      }
#
#      return (ret[,-1]);
# }
# # step.data(subset(raw.prepay.data, select = c("int_spread")), by = 0.5);
#-----------------------------------------------------------------------

