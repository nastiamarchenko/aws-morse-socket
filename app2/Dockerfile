FROM python:3.7
RUN pip install selectors
RUN pip install asyncio
WORKDIR /data
COPY app.py /usr/local/bin/app.py
#COPY file.html /app/templates/file.html
#ENTRYPOINT ["python3.6"]
CMD ["python3.5","/usr/local/bin/app.py"]
