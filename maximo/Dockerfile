
# Use Miniconda base image.......
FROM public.ecr.aws/u7h0g2s9/continuumio/miniconda3:23.5.2-0

# Set working directory
WORKDIR /app

# Copy project files
# COPY . /project

# # Create the .dbt directory and copy the profiles.yml.......
# RUN mkdir -p /root/.dbt
# COPY profiles.yml /root/.dbt/profiles.yml

# Set pip to use Tsinghua mirror (China-friendly)
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install awscli

# Create Conda environment
RUN conda create -n env1 python=3.12 -y && \
    echo "conda activate env1" >> ~/.bashrc

# Activate environment and install Python dependencies with pip
COPY requirements.txt /app
RUN /bin/bash -c "source ~/.bashrc && \
    conda activate env1 && \
    pip install -r requirements.txt"


# Set working directory for container start
#WORKDIR /project
# Default command
CMD ["bash"]

