library(ggplot2)

# Create label datasets
ev.true <- filter(train.final, label == 1)
ev.false <- filter(train.final, label == 0)

ggplot(ev.true, aes(x=val.pct, y=val.per, color=label)) + geom_point(shape=1)

ggplot(train.final, aes(x=house.avg, y=val.var, color=label)) + geom_point(shape=1) +
  geom_smooth(method=lm, se=FALSE)

ggplot(train.final, aes(x=house.avg, y=val.per, color=label)) +
  geom_point(shape=1) +
  geom_smooth(method=glm, se=FALSE)

ggplot(train.final, aes(x=val.pct, y=val.per, color=label)) + geom_point(shape=1)


# Create boxplots of Reading Val Percentile and Percent difference
ggplot(train.final, aes(label, val.per, color = label)) + geom_boxplot()

ggplot(train.final, aes(label, val.pct, color = label)) + geom_boxplot() +
  coord_cartesian(ylim = c(0, 10))

# Check out how Reading Val percentile impacts precision and recall
train.final$sixfive[train.final$val.per >= .65] <- TRUE
train.final$sixfive[train.final$val.per < .65] <- FALSE

train.final$sevenfive[train.final$val.per >= .75] <- TRUE
train.final$sevenfive[train.final$val.per < .75] <- FALSE

train.final$eightfive[train.final$val.per >= .85] <- TRUE
train.final$eightfive[train.final$val.per < .85] <- FALSE

train.final$ninefive[train.final$val.per >= .95] <- TRUE
train.final$ninefive[train.final$val.per < .95] <- FALSE

table(train.final$label, train.final$sixfive)
table(train.final$label, train.final$sevenfive)
table(train.final$label, train.final$eightfive)
table(train.final$label, train.final$ninefive)
