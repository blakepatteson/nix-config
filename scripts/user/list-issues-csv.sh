gh issue list --limit 1000 --json number,title,state,assignees,labels,createdAt \
  | jq -r '["number","title","state","assignees","labels","createdAt"],
    (.[] | [
      (.number|tostring),
      .title,
      .state,
      (.assignees | map(.login) | join(";")),
      (.labels | map(.name) | join(";")),
      .createdAt
    ]) | @csv'
