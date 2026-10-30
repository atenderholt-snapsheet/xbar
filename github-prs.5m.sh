#!/usr/bin/env bash
# <xbar.title>GitHub PRs</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.desc>My open PRs and PRs assigned to / awaiting review from me in bodyshopbidsdotcom</xbar.desc>
# <xbar.dependencies>bash,gh</xbar.dependencies>

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ORG="bodyshopbidsdotcom"
ICON="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"

APPROVED="✅"
CHANGES="❓"
NONE="⚪"
FAILED="❌"

icon_for() {
  case "$1" in
    APPROVED) printf '%s' "$APPROVED" ;;
    CHANGES_REQUESTED) printf '%s' "$CHANGES" ;;
    *) printf '%s' "$NONE" ;;
  esac
}

QUERY='
fragment pr on PullRequest {
  url
  title
  repository { name }
  reviewDecision
  mergeStateStatus
  latestOpinionatedReviews(first: 30) { nodes { state author { login } } }
  commits(last: 1) {
    nodes { commit { statusCheckRollup { contexts(first: 100) { nodes {
      __typename
      ... on CheckRun { conclusion }
      ... on StatusContext { state }
    } } } } }
  }
}
query($mine: String!, $assigned: String!, $requested: String!, $reviewed: String!) {
  viewer { login }
  mine: search(query: $mine, type: ISSUE, first: 50) { nodes { ...pr } }
  assigned: search(query: $assigned, type: ISSUE, first: 50) { nodes { ...pr } }
  requested: search(query: $requested, type: ISSUE, first: 50) { nodes { ...pr } }
  reviewed: search(query: $reviewed, type: ISSUE, first: 50) { nodes { ...pr } }
}'

# Output: section, status, repo, title, url, failing-check count (tab separated).
# My PR status: changes requested wins; approved only counts when the PR isn't BLOCKED.
# Assigned status: my own latest opinionated review.
JQ='
.data.viewer.login as $me
| def reviews: [.latestOpinionatedReviews.nodes[].state];
  def mine_status:
    if (reviews | index("CHANGES_REQUESTED")) then "CHANGES_REQUESTED"
    elif (.reviewDecision == "APPROVED" or (reviews | index("APPROVED"))) and .mergeStateStatus != "BLOCKED" then "APPROVED"
    else "NONE" end;
  def my_status:
    ([.latestOpinionatedReviews.nodes[] | select(.author.login == $me) | .state][0]) // "NONE";
  def fails:
    [.commits.nodes[0].commit.statusCheckRollup.contexts.nodes[]?
      | select((.conclusion // .state // "") | IN("FAILURE", "TIMED_OUT", "STARTUP_FAILURE", "ERROR"))]
    | length;
  def row($section; $status):
    [$section, $status, .repository.name, (.title | gsub("[\t\n|]"; " ")), .url, fails] | @tsv;
  (.data.mine.nodes[] | row("MINE"; mine_status)),
  ([.data.assigned.nodes[], .data.requested.nodes[], .data.reviewed.nodes[]]
    | unique_by(.url) | sort_by(.repository.name, .title)
    | .[] | row("ASSIGNED"; my_status))
'

if ! out=$(gh api graphql \
  -f query="$QUERY" \
  -f mine="is:pr is:open archived:false org:$ORG author:@me" \
  -f assigned="is:pr is:open archived:false org:$ORG assignee:@me" \
  -f requested="is:pr is:open archived:false org:$ORG review-requested:@me" \
  -f reviewed="is:pr is:open archived:false org:$ORG reviewed-by:@me -author:@me" \
  --jq "$JQ" 2>&1); then
  echo "| image=$ICON"
  echo "---"
  echo "gh failed | color=red"
  while IFS= read -r line; do echo "${line//|/¦} | font=Menlo size=11 trim=false"; done <<<"$out"
  exit 0
fi

mine_lines=()
assigned_total=0
assigned_unapproved=0
assigned_out=()   # finished repo submenus
repo_cur=""
repo_unapproved=0
repo_items=()

flush_repo() {
  [ -z "$repo_cur" ] && return
  assigned_out+=("$repo_cur ($repo_unapproved)")
  local item
  for item in "${repo_items[@]}"; do assigned_out+=("--$item"); done
  repo_items=()
}

while IFS=$'\t' read -r section status repo title url fails; do
  [ -z "$url" ] && continue
  suffix="$(icon_for "$status")"
  [ "${fails:-0}" -gt 0 ] && suffix="$suffix $FAILED ($fails)"
  if [ "$section" = "MINE" ]; then
    mine_lines+=("$repo / $title $suffix | href=$url")
  else
    if [ "$repo" != "$repo_cur" ]; then
      flush_repo
      repo_cur="$repo"
      repo_unapproved=0
    fi
    assigned_total=$((assigned_total + 1))
    if [ "$status" != "APPROVED" ]; then
      repo_unapproved=$((repo_unapproved + 1))
      assigned_unapproved=$((assigned_unapproved + 1))
    fi
    repo_items+=("$title $suffix | href=$url")
  fi
done <<<"$out"
flush_repo

echo "| image=$ICON"
echo "---"

echo "My PRs (${#mine_lines[@]}) | size=13"
for l in "${mine_lines[@]}"; do echo "$l"; done

echo "---"

echo "Assigned to Me ($assigned_unapproved) | size=13"
for l in "${assigned_out[@]}"; do echo "$l"; done

echo "---"
echo "Refresh | refresh=true"
