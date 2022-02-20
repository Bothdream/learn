[TOC]

# **1.Snapshot & Restore**

- Snapshot & Restore 步骤：


1. Register a snapshot repository
2. Create a snapshot 
3. Restore a snapshot

ES集群快照备份可以帮助用户：1.在不停机情况下，备份集群数据；2.删除或硬件故障后恢复数据；3.在集群之间传输数据。

- Snapshot 包含的内容

  默认的，快照内容包含集群的状态信息，全部的data stream，全部打开的索引（包括系统索引）。集群的状态信息包含以下几个内容：**(1).持久集群设置，(2).索引模板，(3).旧索引模板，(4).Ingest pipelines，(5).ILM policies**，**(6)对于7.12.0以后的版本，还包括feature states**。快照内容不会包含：**(1).某个时间点的集群配置，(2).已注册的快照存储库的信息，(3).节点的配置文件(如安全配置，启动配置)**。

  ES可以对data-stream做快照，也可以对指定的索引做快照，对索引做快照时，它的索引别名也会包含在快照内容里面，如果恢复快照时，可以指定是否恢复索引的别名。

-  Snapshots 工作原理

  **快照会自动进行重复数据删除，以节省存储空间并降低网络传输成本。为了备份索引，快照会复制索引段的副本并将它们存储在快照存储库中。由于段是不可变的，快照只需要复制自存储库的最后一个快照以来创建的任何新段。每个快照在逻辑上也是独立的。 当删除快照时，Elasticsearch 只会删除该快照专门使用的段。 Elasticsearch 不会删除存储库中其他快照使用的段。**

- Snapshots & Shard allocation

  **快照从索引的主分片复制段。 当启动快照时，Elasticsearch 会立即开始复制任何可用主分片的分段。 如果分片正在启动或重新定位，Elasticsearch 将等待这些过程完成，然后再复制分片的段。 如果一个或多个主分片不可用，快照尝试将失败。**

  **一旦快照开始复制分片的片段，Elasticsearch 不会将分片移动到另一个节点，即使重新平衡或分片分配设置通常会触发重新分配。 Elasticsearch 只会在快照完成复制分片数据后移动分片。**

- Snapshot start & stop times

  快照并不代表精确时间点的集群信息。 相反，每个快照都包含开始时间和结束时间。 快照表示在这两次之间的某个时间点对每个分片数据的视图。**故不能通过复制data目录来备份数据。**

- Snapshot Compatibility

  要将快照恢复到集群，快照、集群和任何恢复的索引的版本必须兼容。请记住这一点：在升级集群之前做快照。

  不能无法将快照还原到低版本的 Elasticsearch。 例如，不能将在 7.6.0 中的快照恢复到运行 7.5.0 的集群。

# 2.Register a snapshot repository

- 前置条件

  要注册快照存储库，集群的全局元数据必须是可写的。 确保没有任何阻止写入访问的集群块。

- 注意

  **1.每个快照存储库都是独立的。 Elasticsearch 不会在存储库之间共享数据**。

  **2.如果将同一个快照存储库注册到多个集群，则只有一个集群应该具有对该存储库的写入权限。 在其他集群上，将存储库注册为只读。**

  这可以防止多个集群同时写入存储库并破坏存储库的内容。 它还可以防止Elasticsearch 缓存存储库的内容，这意味着其他集群所做的更改将立即变得可见。

  **3.为每个主要版本的 Elasticsearch 使用不同的快照仓库。 混合来自不同主要版本的快照可能会损坏存储库的内容。**

- Snapshot repository types

  1.self-managed repository types

​       (1) Shared file system repository

仅当在自己的硬件上运行 Elasticsearch 时，此存储库类型才可用。使用共享文件系统存储库将快照存储在共享文件系统上。**要注册共享文件系统存储库，首先将文件系统挂载到所有主节点和数据节点上的相同位置。 然后将文件系统的路径或父目录添加到每个主节点和数据节点的 elasticsearch.yml 中的 path.repo 设置中。 对于正在运行的集群，这需要滚动重启每个节点。**

注册步骤

a. 设置elasticsearch.yml 的 path.repo 配置

```yaml
path:
  repo:
    - /mount/backups
    - /mount/long_term_backups
```

b.重启每个es节点，调用  [create snapshot repository API] 注册仓库

```console
PUT _snapshot/my_fs_backup
{
  "type": "fs",
  "settings": {
    "location": "/mount/backups/my_fs_backup_location"
  }
}
```

**注意：location 一定是path.repo配置的子目录。**

要使用创建快照存储库 API 将文件系统存储库注册为只读，请将 readonly 参数设置为 true。

```console
PUT _snapshot/my_fs_backup
{
  "type": "fs",
  "settings": {
    "location": "/mount/backups/my_fs_backup_location",
    "readonly": true
  }
}
```

(2)Read-only URL repository

(3)Source-only repository

- Clean up repository

  随着时间的推移，存储库会累积任何现有快照未引用的数据。 这是由于快照功能在快照创建期间的故障场景中提供的数据安全保证以及快照创建过程的分散性质。 **这种未引用的数据绝不会对快照存储库的性能或安全性产生负面影响，但会导致超出必要的存储使用量。 要删除此未引用的数据，可以对存储库运行清理操作。 这将触发对存储库内容的完整记帐并删除任何未引用的数据。**

```console
POST _snapshot/my_repository/_cleanup
```

 The API returns: 

```console-result
{
  "results": {
    "deleted_bytes": 20,
    "deleted_blobs": 5
  }
}
```

# 3.Create a snapshot 

- 前提条件

  **1.只能从正在运行的候选主节点创建快照。**

  2.快照仓库必须已经注册而且可供集群使用。

  3.集群的全局元数据必须是可读的。 要在快照中包含索引，索引及其元数据也必须是可读的。 确保没有任何阻止读取访问的簇块或索引块。

- 注意

  **1.每个快照在其快照仓库中必须具有唯一的名称。 尝试创建与现有快照同名的快照将失败。**

  **2.快照会自动进行重复数据删除。 可以频繁创建快照，而对存储开销的影响很小。**

  **3.每个快照在逻辑上都是独立的。 可以删除快照而不影响其他快照。**

  **4.创建快照将临时暂停分片分配。**

  **5.创建快照不会阻塞索引或其他请求。 但是，快照将不包括在快照过程开始后所做的更改。**

  **6.可以同时创建多个快照。 snapshot.max_concurrent_operations 集群设置限制并发快照操作的最大数量**

  7.如果快照中包含数据流，则快照中包含数据流的后备索引和元数据。

  在创建快照中也可以指定仅包含特定的后备索引。 但是，快照将不会包含数据流的元数据或其他后备索引。

  8.快照可以包括数据流，但不包括特定的后备索引。 当恢复此类数据流时，它仅包含快照中的后备索引。 如果流的原始写入索引不在快照中，则快照中最近的后备索引将成为流的写入索引。

## 使用快照生命周期管理 (SLM) 自动创建和保留快照

待完善

## 手动创建快照

```
语法：PUT _snapshot/<snapshot_repository>/<my_snapshot_{now/d}>
支持 date math 函数。
```

如：

```console
# PUT _snapshot/快照仓库名/快照名
# PUT _snapshot/my_repository/<my_snapshot_{now/d}> 
PUT _snapshot/my_repository/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E
```

根据其大小，快照可能需要一段时间才能完成。 默认情况下，创建快照 API 仅启动快照进程，该进程在后台运行。 要在快照完成之前阻止客户端，请将 wait_for_completion 查询参数设置为 true。

```console
PUT _snapshot/my_repository/my_snapshot?wait_for_completion=true
```

## 监控快照的进度

监视任何当前正在运行的快照，可以使用带有 _current 请求路径参数的获取快照 API。

```console
# 查看正在进行的备份的快照
# 快照创建成功返回为空数组:{
  "snapshots" : [ ]
}
GET _snapshot/my_repository/_current
```

要获得参与任何当前正在运行的快照的每个分片的完整细分，可以使用获取快照状态 API。

```console
# 快照创建成功返回为空数组:{
  "snapshots" : [ ]
}
GET _snapshot/_status
```

以上两个接口可以监控快照的进度以及是否成功，可以用于排查问题。

## 删除或取消快照

```console
# DELETE _snapshot/快照仓库名/快照名
DELETE _snapshot/my_repository/my_snapshot_2099.05.06
```

如果删除正在进行的快照，Elasticsearch 会取消它。 快照进程暂停并删除为快照创建的所有文件。 删除快照不会删除其他快照使用的文件。

## 备份集群配置文件

​		如果自己的硬件上运行 Elasticsearch，建议，除了备份数据之外，还可以使用选择的文件备份软件对每个节点的 $ES_PATH_CONF目录中的文件进行定期备份。 快照不会备份这些文件。根据设置，其中一些配置文件可能包含敏感数据，例如密码或密钥。 如果是这样，请考虑加密备份文件。

# 4.Restore a snapshot

- 前提条件

  **1.只能将快照还原到具有选定主节点的正在运行的集群。 快照仓库库必须已注册并可供集群使用。**

  **2.快照和集群版本必须兼容。**

  3.要恢复快照，集群的全局元数据必须是可写的。 确保没有任何阻止写入的集群块。 还原操作忽略索引块。**4.在恢复数据流之前，请确保集群包含启用数据流的匹配索引模板。如果不存在这样的模板，可以创建一个或恢复包含这个索引模板的集群状态。 如果没有匹配的索引模板，数据流就无法翻转或创建支持索引。**

- 注意

  1.如果恢复一个数据流，则也恢复了它的后备索引。

  2.如果现有索引已关闭并且快照中的索引具有相同数量的主分片，则只能恢复现有索引。

  **3.无法恢复现有的打开索引。 这包括数据流的后备索引。**

  **4.恢复操作会自动打开恢复的索引，包括后备索引。**

  **5.只能从数据流中恢复特定的后备索引。 但是，恢复操作不会将恢复的后备索引添加到任何现有数据流中。**

## 获取可用的快照

```console
# 获取快照仓库
GET _snapshot
```

```console
#  获取所有可用的快照
# GET _snapshot/快照仓库/*?verbose=false
GET _snapshot/my_repository/*?verbose=false
```

## 恢复索引或数据流

默认情况下，恢复请求会尝试恢复快照中的所有索引和数据流，包括系统索引和系统数据流。 在大多数情况下，只需要从快照中恢复特定的索引或数据流。 **但是，无法恢复现有的打开索引。**

​		如果要将数据恢复到预先存在的集群，可以选择以下方法来避免与现有索引和数据流发生冲突：

- 删除并恢复

- 重命名恢复

**一些 Elasticsearch 功能会在集群启动时自动创建系统索引。 为了避免在将数据恢复到新集群时与这些系统索引发生冲突，可以排除系统索引。**

### 删除并恢复

​		避免冲突的最简单方法是在恢复现有索引或数据流之前将其删除。 为防止意外重新创建索引或数据流，建议暂时停止所有索引，直到恢复操作完成。

- 删除索引或数据流

```console
# Delete an index
DELETE my-index

# Delete a data stream
DELETE _data_stream/logs-my_app-default
```

- 恢复索引或数据流

```console
POST _snapshot/my_repository/my_snapshot_2099.05.06/_restore
{
  "indices": "my-index,logs-my_app-default"
}
```

### 重命名恢复

​		如果想避免删除现有数据，可以重命名恢复的索引和数据流。 通常使用此方法将现有数据与快照中的历史数据进行比较。 例如，可以使用此方法在意外更新或删除后查看文档。在开始之前，确保集群有足够的容量容纳现有数据和恢复的数据。

```console
POST _snapshot/my_repository/my_snapshot_2099.05.06/_restore
{
  "indices": "my-index,logs-my_app-default", # 要恢复的索引
  "rename_pattern": "(.+)", #匹配要恢复的索引
  "rename_replacement": "restored-$1" # $1 为匹配到的要恢复的索引，为其加了前缀restored
}
```

如果重命名一个数据流，它的后备索引也会被重命名。 例如，将 logs-my_app-default 数据流重命名为 restore-logs-my_app-default，则后备索引 .ds-logs-my_app-default-2099.03.09-000005 将重命名为 .ds-restored-logs- my_app-default-2099.03.09-000005。

​	还原操作完成后，可以比较原始数据和还原数据。 如果不再需要原始索引或数据流，可以将其删除并使用重新索引来重命名恢复的索引。

```console
# Delete the original index
DELETE my-index

# Reindex the restored index to rename it
POST _reindex
{
  "source": {
    "index": "restored-my-index"
  },
  "dest": {
    "index": "my-index"
  }
}

# Delete the original data stream
DELETE _data_stream/logs-my_app-default

# Reindex the restored data stream to rename it
POST _reindex
{
  "source": {
    "index": "restored-logs-my_app-default"
  },
  "dest": {
    "index": "logs-my_app-default",
    "op_type": "create"
  }
}
```

### 排除系统索引

​		一些 Elasticsearch 功能，例如 GeoIP 处理器，会在启动时自动创建系统索引。 为避免与这些索引发生命名冲突，请使用 -.* 通配符模式从还原请求中排除系统索引和其他点 (.) 索引。

例如，以下请求使用` *,-.* `通配符模式来恢复除点索引之外的所有索引和数据流。

```console
POST _snapshot/my_repository/my_snapshot_2099.05.06/_restore
{
  "indices": "*,-.*"
}
```

## 监控恢复

恢复操作使用分片恢复过程从快照恢复索引的主分片。 当还原操作恢复主分片时，集群将处于黄色健康状态。

恢复所有主分片后，复制过程会在符合条件的数据节点上创建和分发副本。 复制完成后，集群运行状况通常会变为绿色。

```console
GET _cluster/health
```

要获取有关正在进行的分片恢复的详细信息，请使用索引恢复 API。

```console
GET my-index/_recovery
```

要查看任何未分配的分片，请使用 cat shards API。

```console
GET _cat/shards?v=true&h=index,shard,prirep,state,node,unassigned.reason&s=state
```

未分配的分片具有未分配状态。 prirep 值对于主分片是 p，对于副本是 r。 unassigned.reason 描述了分片保持未分配的原因。

## 取消恢复

可以删除索引或数据流以取消其正在进行的恢复。 这也会删除集群中索引或数据流的任何现有数据。 删除索引或数据流不会影响快照或其数据。

```console
# Delete an index
DELETE my-index

# Delete a data stream
DELETE _data_stream/logs-my_app-default
```

# 5.附录

- 索引备份常用API

```
# 1.创建快照仓库
PUT _snapshot/my_fs_backup
{
  "type": "fs",
  "settings": {
    "location": "D:\\elasticsearch-software\\elasticsearch-7.14.1\\backup\\mydata"
  }
}

# 2.创建快照
# 2.1根据自定义的名字创建快照
PUT _snapshot/my_fs_backup/my_snapshot?wait_for_completion=true

# 2.2根据日期函数创建date 创建快照
# PUT _snapshot/my_fs_backup/<my_snapshot_{now/d}>
PUT _snapshot/my_fs_backup/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E?wait_for_completion=true
{
  "ignore_unavailable": true,
  "include_global_state": false
}

# 3.恢复快照
# 3.1查询所有的快照仓库
GET _snapshot

# 3.2查找指定快照仓库下的所有快照
GET _snapshot/my_fs_backup/*?verbose=false
GET _snapshot/my_fs_backup/_all?verbose=false

# 3.3 删除并恢复索引
# 直接恢复会因为有同名的索引而报错，简单的处理方式是先删除索引，再恢复。
# 为防止意外重新创建索引或数据流，我们建议您暂时停止所有索引，直到恢复操作完成。
DELETE /my-index-000001

GET /_cat/indices

# 恢复指定的索引
POST _snapshot/my_fs_backup/my_snapshot_2022.02.13/_restore
{
  "indices": "my-index-000001"
}

GET /_cat/indices

# 3.4 重命名恢复索引
# 如果不想删除现存的来恢复索引，可以对需要恢复的索引进行重命名。
# 在恢复之前，需要保证集群有足够的容量，因为重名的索引和原始索引都存在。

# 查看my_fs_backup仓库下所有的快照信息
GET _snapshot/my_fs_backup/*

# 利用正则匹配将my-index-000001 恢复成 restored-my-index-000001
POST _snapshot/my_fs_backup/my_snapshot/_restore
{
  "indices": "my-index-000001",
  "rename_pattern": "(.+)",
  "rename_replacement": "restored-$1"
}
# 3.4.1 当恢复操作完成以后，如果想删除原始的索引，可以先删除原始索引，然后用
# reindex API来重命名恢复的索引
# 删除原始索引
DELETE my-index-000001

# Reindex 恢复的索引

POST _reindex
{
  "source": {
    "index": "restored-my-index-000001"
  },
  "dest": {
    "index": "my-index-000001"
  }
}

# 3.4.2 排除系统索引
# 利用 *,-.* 通配符可恢复除系统索引以及和点以外的索引
POST _snapshot/my_fs_backup/my_snapshot/_restore
{
  "indices": "*,-.*",
  "rename_pattern": "(.+)",
  "rename_replacement": "restored-exclude-$1"
}

# 3.4.3 删除快照
# 删除指定的快照my_snapshot
DELETE _snapshot/my_fs_backup/my_snapshot

# 删除指定的快照仓库
# 只是删除仓库，数据还在
DELETE _snapshot/my_fs_backup

# 查看分片状态
GET _cat/shards
GET _cat/shards?v=true&h=index,shard,prirep,state,node,unassigned.reason&s=state
```

