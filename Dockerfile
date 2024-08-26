FROM archlinux:latest

COPY *.* /*.*

ENTRYPOINT ["/entrypoint.sh"]
