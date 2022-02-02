import os

cdn_url = os.getenv('CDN_URL')
app_version = os.getenv('APP_VERSION')

def handler(event, context):
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "statusDescription": "200 OK",
        "headers": {
            "Content-Type": "text/html"
        },
        "body": f"""
        <html>
        <head><title>David Smith - Checkout Challenge</title></head>
        <body>
        <h1>Hello there!</h1>
        <h2>This is the checkout test website.</h2>
        <pre>(version {app_version})</pre> 
        <img src=\"{cdn_url}explosion.gif\">
        </body>
        </html>
        """
    }