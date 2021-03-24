

# path of the file to upload to gcp (the path of the file should be absolute or should match the directory where the make command is run)
LOCAL_PATH="/Users/felipeinostroza/code/FelipeDS-Chili/TaxiFareModel/TaxiFareModel/data/train_1k.csv"

# bucket directory in which to store the uploaded file (we choose to name this data as a convention)
BUCKET_FOLDER=data

# name for the uploaded file inside the bucket folder (here we choose to keep the name of the uploaded file)
# BUCKET_FILE_NAME=another_file_name_if_I_so_desire.csv
BUCKET_FILE_NAME=$(shell basename ${LOCAL_PATH})

# project id  # Replace with your Project's ID
PROJECT_ID=wagon-bootcamp-307723

# bucket name
BUCKET_NAME=wagon-ml-felipeinostrozarios-21

 # Choose your region https://cloud.google.com/storage/docs/locations#available_locations

BUCKET_TRAINING_FOLDER = 'trainings'

REGION=southamerica-east1

PYTHON_VERSION=3.7
FRAMEWORK=scikit-learn
RUNTIME_VERSION=1.15

PACKAGE_NAME=TaxiFareModel
FILENAME=trainer


JOB_NAME=taxi_fare_training_pipeline_$(shell date +'%Y%m%d_%H%M%S')


set_project:
	-@gcloud config set project ${PROJECT_ID}

#crear un bucket dentro de un proyecto
create_bucket:
	-@gsutil mb -l ${REGION} -p ${PROJECT_ID} gs://${BUCKET_NAME}

#subir data.csv a storage GCP
upload_data:
	-@gsutil cp ${LOCAL_PATH} gs://${BUCKET_NAME}/${BUCKET_FOLDER}/${BUCKET_FILE_NAME}

# correr el packete
run_locally:
	@python -m ${PACKAGE_NAME}.${FILENAME}

# funcion para entrenar un modelo en gcp
gcp_submit_training:
	gcloud ai-platform jobs submit training ${JOB_NAME} \
		--job-dir gs://${BUCKET_NAME}/${BUCKET_TRAINING_FOLDER} \
		--package-path ${PACKAGE_NAME} \
		--module-name ${PACKAGE_NAME}.${FILENAME} \
		--python-version=${PYTHON_VERSION} \
		--runtime-version=${RUNTIME_VERSION} \
		--region ${REGION} \
		--stream-logs



clean:
	@rm -f */version.txt
	@rm -f .coverage
	@rm -fr */__pycache__ __pycache__
	@rm -fr build dist *.dist-info *.egg-info
	@rm -fr */*.pyc




install_requirements:
	@pip install -r requirements.txt

check_code:
	@flake8 scripts/* TaxiFareModel/*.py

black:
	@black scripts/* TaxiFareModel/*.py

test:
	@coverage run -m pytest tests/*.py
	@coverage report -m --omit="${VIRTUAL_ENV}/lib/python*"

ftest:
	@Write me



install:
	@pip install . -U

all: clean install test black check_code


uninstal:
	@python setup.py install --record files.txt
	@cat files.txt | xargs rm -rf
	@rm -f files.txt

count_lines:
	@find ./ -name '*.py' -exec  wc -l {} \; | sort -n| awk \
        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''
	@find ./scripts -name '*-*' -exec  wc -l {} \; | sort -n| awk \
		        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''
	@find ./tests -name '*.py' -exec  wc -l {} \; | sort -n| awk \
        '{printf "%4s %s\n", $$1, $$2}{s+=$$0}END{print s}'
	@echo ''

# ----------------------------------
#      UPLOAD PACKAGE TO PYPI
# ----------------------------------
PYPI_USERNAME=<AUTHOR>
build:
	@python setup.py sdist bdist_wheel

pypi_test:
	@twine upload -r testpypi dist/* -u $(PYPI_USERNAME)

pypi:
	@twine upload dist/* -u $(PYPI_USERNAME)
