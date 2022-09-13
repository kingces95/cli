URL=https://content.googleapis.com/drive/v3/drives
KK_BEARER_TOKEN=ya29.a0AVA9y1s5Dbd9pKA5ek6vyqmJtdqOlKFREFTkSQPyEJ3PzU-N6NAPiiclFI-SsikOtEUzeQecZ22Nw69MGAnx2eFLFr2BmgL3HnPYkLXKFhgLMOIP4wsKpR54y3uXdC1hL2_ikN1v9p69Zcx9jNmprC3LhaOQj8sIJQaCgYKATASARMSFQE65dr8TfYz4DPysSfGcK_KDjoeuQ0169

curl "${URL}" \
   -H "Accept: application/json" \
   -H "Authorization: Bearer ${KK_BEARER_TOKEN}" \
   --referer https://content.googleapis.com/static/proxy.html?usegapi=1 \
   -G \
   -d useDomainAdminAccess=true \
   -d key=AIzaSyAa8yy0GdcGPHdtD083HiGGx_S0vMPScDM
