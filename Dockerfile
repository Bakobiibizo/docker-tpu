FROM gcr.io/tpu-pytorch/xla:nightly
WORKDIR /root

# Installs Tensorflow to resolve the TPU name to IP Address
RUN pip install tensorflow

# Installs google cloud sdk, this is mostly for using gsutil to    
# export the model.
RUN wget -nv \\
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \\
    mkdir /root/tools && \\
    tar xvzf google-cloud-sdk.tar.gz -C /root/tools && \\
    rm google-cloud-sdk.tar.gz && \\
    /root/tools/google-cloud-sdk/install.sh --usage-reporting=false \\
    --path-update=false --bash-completion=false \\
    --disable-installation-options && \\
    rm -rf /root/.config/* && \\
    ln -s /root/.config /config && \\
    # Remove the backup directory that gcloud creates
    rm -rf /root/tools/google-cloud-sdk/.install/.backup

# Path configuration
ENV PATH $PATH:/root/tools/google-cloud-sdk/bin

# Make sure gsutil will use the default service account
RUN echo '[GoogleCompute]\\nservice_account = default' > /etc/boto.cfg

# Set work directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app/

# Use ARG for build-time variables
ARG HUGGINGFACE_API_KEY
ARG OPENAI_API_KEY
ARG ANTHROPIC_API_KEY

# Use ENV for runtime variables
ENV HUGGINGFACE_API_KEY=$HUGGINGFACE_API_KEY
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# Install packages
RUN python install.py

# Change the below to your exec. Make sure you chmod +x the script first
ENTRYPOINT ["sh", "run.sh"]