# Exploring security weaknesses against Kubernetes

## Collaborators

* [Russ Miles](https://chaosiq.io/)
* [Andrew Martin](https://control-plane.io/)

## Experiments

### Unauthorised Access to Etc.d

This experiment looks at whether direct access to Etc.d is prevented by _only_ network policies. Ideally this protection should be multi-level, perhaps also implemented by 
segregating the underlying VMs from everything except the API server.
