#!/usr/bin/env bash
# <xbar.title>Sail Tinker</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.desc>Lists vice-backend ECS clusters across regions; click one to open `sail tinker` in a new terminal window</xbar.desc>
# <xbar.dependencies>bash,aws,sail</xbar.dependencies>

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SAIL="/usr/local/bin/sail"
PROJECT="vice-backend"
REGIONS=(us-east-1 us-east-2 us-west-2)
# Only clusters whose name contains this are listed
FILTER="vice-backend"

ICON="iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAAACXBIWXMAABYlAAAWJQFJUiTwAAAEJ0lEQVR42u2Xe2hOYRzHX2zDXDbX/GF/uBYKuWekpUj+kcsWIn8IxT8kMaWUWInXcM6rUMslyT9DSCFsrZHIPXK/t40mY8y8j+/vd76b5z1j73m35a+d+vS87znP8zu/5/f8bicUar1ar/95RUy7kGvSQCbIA0Uhx5RhjCre7yI+kznpuqbFL0cVyQDZ4ByoBiYAxSBH1zotpVjEtIfAGaDQetEv8AGUggughlZ6A0rAC/DDml+oMkRWMy3TGYIWgof1x+KaZyAfz5ZgnAA20mLvcG8ZxpFgLtgOblP5KGUsVJnNsIwo84BC63Y6FXTVOa6ZAu6BcrxocShsOtavlzmumQgOWFZ9oDITtpTnMzO4K08Zx7gY+1oKd8H/gzyuLVAm5a+yXNMbLMf6r5T1UGUn5FOeAxfS1LK7Q6Cbb85M8Ag8Ab3ibLCDKuXJilJ2RiKhneOLlrkx4RvR49jDHS8FyXxpd4zDMM4Dmxj+wjbc34rxliUzO1hKkNzhhaut0H4ItP1DnPkm7t0Fk8lu3LuP8RvG76BSfcvV3PQJfLF80TB9pAVRKNNa9IpCn4OBtE5bWrCSSfAElKi01nwEx8F6sAJI5K0GmzHvsOWX1fquAArlUfA3hm4Bd5zH56kgt5FkWK4Wdc2oBkciVnbMKuYwUy8zjkJFnCxWmQOmMdGJ6QdDYE+MkTgZWpLiFTp+kk++HPcNRm5RkJAvo1DxETm+jmAXw/skGK7HFL9syLG8VAePlS8RfJ4KlQWxUF2ol2jW9YT0wu+73PklcC1gLROqwDgrQrtZZSjaNIU8pYZQeFBFJCufUed1EBwR079pCv05sutgrE/ZeSygQRS6p47tvfwnOAoku/djQQ58ZHVO/RTM8j1LYgtS6qvm/2o9BmgguOYxeA8WgNFcH9Cp/4R9leaSiK9GhRHKezVSjjHh/UshKTd9KFOK9FdaaSV4m0jYZ1oNmCSxnRQiKWAyyALzwQ5asS771tLZL3L3uaE9yFmeG3THvavgNbjDIzRBE2M6c4ixEmQFfecp+6G3vPcdL6tijVqqPueaffrMMbNhzTaUmQLWMWB+WUeaHl+hfD2SHF/5OAIuU0gx84jkpkV48VD22UnMUaLsaTDI2qRYaTxbEE+uvCM/aAvSsP1YE1Nc/74mlf73GXM3wjqdrNyTzC6ywmo/+ja9QZOdOXokPRpRaDrLi1hwjCUrlcqUWw1aVuItbBhtpmO1sJ6588GIBi2oq8dWwkov1pT+KEmPzTVraRmvhRWZ4aY2+9KQOzFNfi0dfgOYpBYTa7jmLGtdAZUbg3UrWftq6pt8pzlNvm2php9BX7T4uuYUQ72WLz7PeddorWjMZ1C4uZ9B/g9FL/qKG0mGNdbvau0K92pmb8EPRX9K8PJU0E/ptOCh3Xq1Xi1z/QZ26FiTb6oaxgAAAABJRU5ErkJggg=="

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for region in "${REGIONS[@]}"; do
  aws ecs list-clusters --region "$region" --query 'clusterArns[]' --output text \
    >"$tmp/$region.out" 2>"$tmp/$region.err" &
done
wait

rows=()   # "display<TAB>cluster<TAB>region"
errors=()
for region in "${REGIONS[@]}"; do
  if [ -s "$tmp/$region.err" ]; then
    errors+=("$region: $(head -n 1 "$tmp/$region.err")")
    continue
  fi
  for arn in $(cat "$tmp/$region.out"); do
    cluster="${arn##*/}"
    [[ "$cluster" == *"$FILTER"* ]] || continue
    display="${cluster#"$PROJECT"-}"
    rows+=("$(printf '%s\t%s\t%s' "$display" "$cluster" "$region")")
  done
done

echo "| image=$ICON"
echo "---"

if [ ${#rows[@]} -gt 0 ]; then
  while IFS=$'\t' read -r display cluster region; do
    echo "$display ($region) | bash=$SAIL param1=tinker param2=run param3=-p param4=$PROJECT param5=-e param6=$display param7=--region param8=$region param9=bash terminal=true"
  done < <(printf '%s\n' "${rows[@]}" | sort -t$'\t' -k1,1 -k3,3)
elif [ ${#errors[@]} -eq 0 ]; then
  echo "No $FILTER clusters found | color=gray"
fi

for e in "${errors[@]}"; do
  echo "$e | color=red font=Menlo size=11 trefresh=false"
done

echo "---"
echo "Refresh | refresh=true"
