# ions

## Development

Since we rely on CodePipeline for our `stage` and `prod` deployments, instead of the Datomic standard `push`/`deploy`, we've got a single `release` command for `dev`.

```bash
./bin/release.sh
``` 
