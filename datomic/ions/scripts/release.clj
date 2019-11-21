(ns release
  (:require [clojure.edn :as edn]
            [clojure.pprint :refer [pprint]]
            [clojure.stacktrace :as st]
            [datomic.ion.dev :as ion-dev])
  (:gen-class))

; Adapted from Oliver George: https://gist.github.com/olivergeorge/f402c8dc8acd469717d5c6008b2c611b

(defn- release
  [args]
  (pprint args)
  (try
    (let [push-data (ion-dev/push (select-keys args [:uname :creds-profile :region]))]
      (pprint push-data)
      (let [deploy-args (merge (select-keys args [:group :uname :creds-profile :region])
                               (select-keys push-data [:rev]))
            deploy-data (ion-dev/deploy deploy-args)
            status-args (merge (select-keys args [:creds-profile :region])
                               (select-keys deploy-data [:execution-arn]))]
        (pprint deploy-data)
        (loop []
          (let [status-data (ion-dev/deploy-status status-args)]
            (if (or (= "RUNNING" (:deploy-status status-data))
                    (= "RUNNING" (:code-deploy-status status-data)))
              (do
                (pprint status-data)
                (Thread/sleep 5000)
                (recur))
              status-data)))))
    (catch Exception e
      (st/print-cause-trace e)
      {:deploy-status "ERROR"
       :message (.getMessage e)})))

(defn -main
  [& args]
  (let [args (edn/read-string (first args))
        release-data (release args)]
    (pprint release-data)
    (shutdown-agents)
    (if (and (= "SUCCEEDED" (:deploy-status release-data))
             (= "SUCCEEDED" (:code-deploy-status release-data)))
      (System/exit 0)
      (System/exit 1))))
