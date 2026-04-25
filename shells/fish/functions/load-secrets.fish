function load-secrets --description "Decrypt and export store-managed secrets into this shell"
    set -l names ANTHROPIC_API_KEY OPENAI_API_KEY GITHUB_TOKEN NPM_TOKEN VERCEL_TOKEN

    read -s -P "store passphrase: " passphrase
    if test -z "$passphrase"
        echo "load-secrets: aborted, passphrase empty" >&2
        return 1
    end

    set -l loaded 0
    set -l missing
    for name in $names
        set -l value (env STORE_PASSPHRASE=$passphrase store secret get $name 2>/dev/null)
        if test -n "$value"
            set -gx $name $value
            set loaded (math $loaded + 1)
        else
            set -a missing $name
        end
    end

    if test $loaded -eq 0
        echo "load-secrets: nothing loaded. Wrong passphrase, or no secrets set yet (run 'store secret set <NAME>')." >&2
        return 1
    end

    echo "load-secrets: exported $loaded of "(count $names)" secrets"
    if test (count $missing) -gt 0
        echo "load-secrets: not set: $missing"
    end
end
