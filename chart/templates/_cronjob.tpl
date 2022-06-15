{{ define "grafana-reporter.cronjob" }}
kind: CronJob
apiVersion: batch/v1
metadata:
  name: "{{ .Release.Name }}-{{ .cronname }}"
  labels:
    app: "{{ .Chart.Name }}"
    chart: "{{ .Chart.Name }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  schedule: "{{ .schedule }}"
  concurrencyPolicy: "Forbid"
  jobTemplate:
    metadata:
      name: "{{ .Release.Name }}-{{ .cronname }}"
      labels:
        app: {{ .Chart.Name }}
        role: cronjobs
        chart: "{{ .Chart.Name }}"
        release: "{{ .Release.Name }}"
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      backoffLimit: 0
      template:
        metadata:
          labels:
            app: "{{ .Chart.Name }}"
            role: cronjobs
            release: "{{ .Release.Name }}"
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          nodeSelector:
{{ toYaml .Values.nodeSelector | indent 12 }}
          affinity:
{{ toYaml .Values.affinity | indent 12 }}
          tolerations:
{{ toYaml .Values.tolerations | indent 12 }}
          dnsPolicy: ClusterFirst
          restartPolicy: Never
          containers:
          - name: "{{ .Release.Name }}-{{ .cronname }}"
            image: curlimages/curl
            imagePullPolicy: Always
            command:
              - "/bin/sh"
            args:
              - "-c"
              - "/scripts/generateReport.sh"
            env:
            - name: CRON_NAME
              value: {{ .cronname }}
            - name: DASHBOARD_ID
              value: {{ .dashboardId }}
            - name: DISCORD_MESSAGE
              value: {{ .message }}
            volumeMounts:
              - name: scripts
                mountPath: "/scripts"
                readOnly: true
          volumes:
          - name: scripts
            configMap:
              name: {{ .Release.Name }}-config
              defaultMode: 0777
{{ end }}
