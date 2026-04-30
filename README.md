# eck-recipe

This is a quick repo for me to store the configs as I play with them.

## current status

In constant flux

## upgrades

### fleet signing key error

If you get the error: `Cannot read existing message signing key pair` you did something wrong.
My cluster is small, so upgrading can be difficult and I ended up removing `kibana`, `fleet server`, and the agents.
This somehow resulted in the above error.
To correct it I needed to do the following (thanks to [this message](https://github.com/elastic/kibana/issues/176528#issuecomment-1936330383):

```
## create a role and temporary user to deal with the problem

POST _security/role/system-index-superuser
{
  "indices": [
    {
      "names": ["*"],
      "privileges": ["all"],
      "allow_restricted_indices": true
    }
  ]
}

POST _security/user/temp_user
{
  "password": "temporary",
  "roles": [
    "superuser",
    "system-index-superuser"
  ]
}

## login as the temp_user and delete the message signing key

GET .kibana_ingest/_search?q=type:fleet-message-signing-keys

POST .kibana_ingest/_delete_by_query
{
  "query": {
    "bool": {
      "filter": [
        {
          "match": {
            "type": "fleet-message-signing-keys"
          }
        }
      ]
    }
  }
}

## Verify the latest agent policy revision is created in .fleet-policies and sent to agents
GET .kibana_ingest/_doc/ingest-agent-policies:<policy_id>

### revision_idx should match the revision of the SO above
GET .fleet-policies/_search?q=policy+id:<policy_id>
{
  "size": 1,
  "sort": [
    {
      "revision_idx": {
        "order": "desc"
      }
    }
  ]
}

## delete temp stuff
DELETE _security/user/temp_user
DELETE _security/role/system-index-superuser

```

## to do

- livenessProbe
- cert-manager
- figure out storage

## outline

- install k3s
- install cert-manager
- setup cert-manager
- install rancher
- setup rancher
- install eck
- install elasticsearch
- install kibana
- install elastic-agent/fleet

