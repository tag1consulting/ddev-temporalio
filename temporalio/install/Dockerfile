FROM python:3.14-slim
RUN pip install ruamel.yaml
WORKDIR /app
COPY ./temporalio/install/yaml-patch.py /usr/local/bin/yaml-patch
RUN chmod +x /usr/local/bin/yaml-patch
ENTRYPOINT ["python", "/usr/local/bin/yaml-patch"]
