FROM public.ecr.aws/lambda/python:3.13

# Copy function code and runtime helpers
COPY examples/basic/lambda/lambda_module.py ${LAMBDA_TASK_ROOT}
COPY src/cloud_cron ${LAMBDA_TASK_ROOT}/cloud_cron

# Set the Lambda handler
CMD ["lambda_module.handler"]
