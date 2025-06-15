ARG MELTANO_IMAGE=meltano/meltano:latest
FROM $MELTANO_IMAGE

RUN apt update && \
    apt install -y curl && \
    apt install -y unzip

RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

WORKDIR /projects/tap-mssql

COPY ./.meltano ./.meltano
COPY ./meltano.yml ./meltano.yml

# Install dependencies
RUN meltano lock --update --all && \
    meltano install

# Copy the entrypoint script
COPY ./entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh


ENTRYPOINT ["./entrypoint.sh"]