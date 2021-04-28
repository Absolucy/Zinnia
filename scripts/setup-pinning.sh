#!/bin/bash
openssl s_client -connect aiwass.aspenuwu.me:443 -showcerts < /dev/null | openssl x509 -outform DER > res/aiwass.der
openssl x509 -pubkey -noout -in res/aiwass.der -inform DER | openssl ec -outform DER -pubin -in /dev/stdin > res/aiwass.key.der
