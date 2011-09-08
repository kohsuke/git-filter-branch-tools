#!/usr/bin/ruby
# Executed like the following to trim off pointless commits (including merge commits)
# that doesn't change the tree 
#   git filter-branch -f --commit-filter '~/ws/jenkins/split2/helper.rb "$@"' HEAD
#
# parameters are "<tree> [ -p <parent> ]*" and is the same as git commit-tree

# system "echo executing #{ARGV.join(' ')} >> /tmp/log"

# extract parents
parents=[]
i=2
while i<ARGV.size do
  parents << ARGV[i]
  i+=2
end
parents=parents.uniq

tree=ARGV[0]

# is the commit 'c' already an ancestor of any of the commits given in 'commits'?
def subsumed_by(c,commits)
  commits.find do |c2|
    c!=c2 && c==`git merge-base #{c} #{c2}`.chomp()
  end
end

# only keep commits that are not subsumed by others
# subsumed parents are pointless merge
parents = parents.select do |p|
  !subsumed_by(p,parents)
end

# does any parent has a different tree?
non_empty_commit = parents.find do |p|
  tree != `git rev-parse #{p}^{tree}`.chomp()
end

if non_empty_commit!=nil || parents.size==0 then
  # if a commit has non-empty diff, make a commit
  args = []
  args << tree
  parents.each{ |c| args << "-p"; args << c; }
  # system "echo git commit-tree #{args.join(' ')} >> /tmp/log"
  exec "git commit-tree #{args.join(' ')}"
else
  # system "echo skipping >> /tmp/log"
  # otherwise don't create this as a commit
  puts parents  
end


