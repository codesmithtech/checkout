FROM amazon/aws-lambda-python:3.9

COPY ./src/. ${LAMBDA_TASK_ROOT}

CMD ["lambda_entry.handler"]