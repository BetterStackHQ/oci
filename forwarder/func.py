import gzip
import io
import os
import urllib.request

from fdk import response


def handler(ctx, data: io.BytesIO = None):
    # Connector Hub retries a batch when the function fails, so a non-2xx
    # response from Better Stack is left to raise.
    request = urllib.request.Request(
        f"https://{os.environ['BETTERSTACK_INGESTING_HOST']}/oci",
        data=gzip.compress(data.getvalue()),
        headers={
            "Authorization": f"Bearer {os.environ['BETTERSTACK_SOURCE_TOKEN']}",
            "Content-Type": "application/json",
            "Content-Encoding": "gzip",
        },
        method="POST",
    )
    urllib.request.urlopen(request, timeout=60)
    return response.Response(ctx, response_data="")
