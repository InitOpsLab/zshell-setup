# === General Aliases ===
alias ls='gls --color=auto'
alias ll='ls -laFh --group-directories-first'
alias please="sudo"
alias s="source ~/.zshrc"
alias notes='nvim ~/notes/notes.org'
alias inbox="nvim ~/notes/inbox.org"

# show listening processes
alias whoslistening="sudo lsof -nP -i4TCP | grep LISTEN"

# networking
alias copyip="curl https://api.ipify.org | pbcopy"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

# base64
alias pastebase64="pbpaste | base64 -d"

# === Dev Aliases ===
alias push-upstream='git push --set-upstream origin $(git branch --show-current)'
alias clean-terragrunt='find . -name ".terraform.lock.hcl" -exec rm -f {} \; && find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;'

# git
alias cb='git symbolic-ref --short HEAD | tr -d "\n" | pbcopy'
list_recent_branches() {
    git for-each-ref --sort=-committerdate refs/heads/ | head -n 15 | awk '{gsub(/[a-zA-Z0-9]+ commit/,"");print}'| awk '{gsub(/refs\/heads\//, "");print}' | awk '{print NR-1 " " $1}'
}

function recent_branches(){
    list_recent_branches
    echo "which branch would you like to checkout?"
    read branch
    git checkout $(list_recent_branches | grep "\b$branch\b" | awk '{print $2}')
}

# === IDE Aliases ===
alias c='cursor --reuse-window .'

# === Kubernetes Aliases ===
alias k=kubectl
alias ka='kubectl get pods'
alias kaf='kubectl apply -f'
alias kall='kubectl get pods --all-namespaces'
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'
alias kccc='kubectl config current-context'
alias kcdc='kubectl config delete-context'
alias kcgc='kubectl config get-contexts'
alias kcl='kubectl config get-contexts'
alias kcn='kubectl config set-context --current --namespace'
alias kcp='kubectl cp'
alias kcsc='kubectl config set-context'
alias kcuc='kubectl config use-context'
alias kdcj='kubectl describe cronjob'
alias kdcm='kubectl describe configmap'
alias kdd='kubectl describe deployment'
alias kdds='kubectl describe daemonset'
alias kdel='kubectl delete'
alias kdelcj='kubectl delete cronjob'
alias kdelcm='kubectl delete configmap'
alias kdeld='kubectl delete deployment'
alias kdelds='kubectl delete daemonset'
alias kdelf='kubectl delete -f'
alias kdeli='kubectl delete ingress'
alias kdelj='kubectl delete job'
alias kdelno='kubectl delete node'
alias kdelns='kubectl delete namespace'
alias kdelp='kubectl delete pods'
alias kdelpvc='kubectl delete pvc'
alias kdels='kubectl delete svc'
alias kdelsa='kubectl delete sa'
alias kdelsec='kubectl delete secret'
alias kdelss='kubectl delete statefulset'
alias kdi='kubectl describe ingress'
alias kdj='kubectl describe job'
alias kdno='kubectl describe node'
alias kdns='kubectl describe namespace'
alias kdp='kubectl describe pods'
alias kdpvc='kubectl describe pvc'
alias kdrs='kubectl describe replicaset'
alias kds='kubectl describe svc'
alias kdsa='kubectl describe sa'
alias kdsec='kubectl describe secret'
alias kdss='kubectl describe statefulset'
alias kecj='kubectl edit cronjob'
alias kecm='kubectl edit configmap'
alias ked='kubectl edit deployment'
alias keds='kubectl edit daemonset'
alias kei='kubectl edit ingress'
alias kej='kubectl edit job'
alias keno='kubectl edit node'
alias kens='kubectl edit namespace'
alias kep='kubectl edit pods'
alias kepvc='kubectl edit pvc'
alias kers='kubectl edit replicaset'
alias kes='kubectl edit svc'
alias kess='kubectl edit statefulset'
alias keti='kubectl exec -t -i'
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'
alias kgcj='kubectl get cronjob'
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgds='kubectl get daemonset'
alias kgdsw='kgds --watch'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kgj='kubectl get job'
alias kgno='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpall='kubectl get pods --all-namespaces -o wide'
alias kgpl='kgp -l'
alias kgpn='kgp -n'
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kgrs='kubectl get replicaset'
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'
alias kn=kubectl-neat
alias kp='xdg-open '\''http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/'\'' & kubectl proxy'
alias kpf='kubectl port-forward'
alias krh='kubectl rollout history'
alias krsd='kubectl rollout status deployment'
alias krsss='kubectl rollout status statefulset'
alias kru='kubectl rollout undo'
alias ksd='kubectl scale deployment'
alias ksss='kubectl scale statefulset'
alias ku=kubectl
alias kw='watch kubectl get'
alias kwa='watch kubectl get pods'
alias kwall='watch kubectl get pods --all-namespaces'
