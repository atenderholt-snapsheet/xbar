#!/usr/bin/env bash
# <xbar.title>GitHub PRs</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.desc>My open PRs and PRs assigned to / awaiting review from me in bodyshopbidsdotcom</xbar.desc>
# <xbar.dependencies>bash,gh</xbar.dependencies>

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ORG="bodyshopbidsdotcom"
# TODO: replace with your base64-encoded octocat PNG
ICON="OCTOCAT_BASE64_PLACEHOLDER"

APPROVED="✅"
CHANGES="❓"
NONE="⚪"

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
  latestOpinionatedReviews(first: 30) { nodes { state author { login } } }
}
query($mine: String!, $assigned: String!, $requested: String!, $reviewed: String!) {
  viewer { login }
  mine: search(query: $mine, type: ISSUE, first: 50) { nodes { ...pr } }
  assigned: search(query: $assigned, type: ISSUE, first: 50) { nodes { ...pr } }
  requested: search(query: $requested, type: ISSUE, first: 50) { nodes { ...pr } }
  reviewed: search(query: $reviewed, type: ISSUE, first: 50) { nodes { ...pr } }
}'

# Status of my own PR: changes requested wins, then approved.
# Status of someone else's PR: my latest opinionated review.
JQ='
.data.viewer.login as $me
| def reviews: [.latestOpinionatedReviews.nodes[].state];
  def mine_status:
    if (reviews | index("CHANGES_REQUESTED")) then "CHANGES_REQUESTED"
    elif .reviewDecision == "APPROVED" or (reviews | index("APPROVED")) then "APPROVED"
    else "NONE" end;
  def my_status:
    ([.latestOpinionatedReviews.nodes[] | select(.author.login == $me) | .state][0]) // "NONE";
  def row($status): [$status, .repository.name, (.title | gsub("[\t\n|]"; " ")), .url] | @tsv;
  ("MINE", (.data.mine.nodes[] | row(mine_status))),
  ("ASSIGNED", ([.data.assigned.nodes[], .data.requested.nodes[], .data.reviewed.nodes[]]
      | unique_by(.url) | .[] | row(my_status)))
'

if ! out=$(gh api graphql \
  -f query="$QUERY" \
  -f mine="is:pr is:open archived:false org:$ORG author:@me" \
  -f assigned="is:pr is:open archived:false org:$ORG assignee:@me" \
  -f requested="is:pr is:open archived:false org:$ORG review-requested:@me" \
  -f reviewed="is:pr is:open archived:false org:$ORG reviewed-by:@me -author:@me" \
  --jq "$JQ" 2>&1); then
  echo "| templateImage=$ICON"
  echo "---"
  echo "gh failed | color=red"
  while IFS= read -r line; do echo "$line | font=Menlo size=11 trefresh=false"; done <<<"$out"
  exit 0
fi

mine_lines=()
assigned_lines=()
section=""
while IFS=$'\t' read -r status repo title url; do
  case "$status" in
    MINE | ASSIGNED) section="$status"; continue ;;
  esac
  [ -z "$url" ] && continue
  if [ "$section" = "MINE" ]; then
    mine_lines+=("$title $(icon_for "$status") | href=$url")
  else
    assigned_lines+=("$repo / $title $(icon_for "$status") | href=$url")
  fi
done <<<"$out"

echo "| templateImage=$ICON"
echo "---"

echo "My PRs (${#mine_lines[@]}) | size=13"
for l in "${mine_lines[@]}"; do echo "$l"; done

echo "---"

echo "Assigned to Me (${#assigned_lines[@]}) | size=13"
for l in "${assigned_lines[@]}"; do echo "$l"; done

echo "---"
echo "Refresh | refresh=true"
