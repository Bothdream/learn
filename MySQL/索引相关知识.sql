一、 创建索引的两种方式：
1.单列索引
 CREATE INDEX `index_name` on table_name(column_name);
 ALTER table_name ADD key `index_name`(column_name);
2.多列索引
 CREATE INDEX `index_name` on table_name(column_name1,column_name2);
 ALTER table_name ADD key `index_name`(column_name1,column_name2);
3.删除索引
 DROP INDEX `index_name` ON table_name;
二、查看执行计划 EXPLAIN
1.全值匹配
EXPLAIN SELECT * FROM t_user WHERE  enabled_flag = 'Y' AND  user_name = '张三';
2.匹配最左前缀
EXPLAIN SELECT * FROM t_user WHERE  user_name = '张三';
3.匹配列前缀
EXPLAIN SELECT * FROM t_user WHERE  user_name like '张%';
4.全盘扫描
EXPLAIN SELECT * FROM t_user WHERE enabled_flag = 'Y';
5.const-常量优化
EXPLAIN SELECT * FROM t_user WHERE enabled_flag = 'Y' AND user_id = 18;
6.访问类型是 range 范围查找 
EXPLAIN SELECT * FROM t_user WHERE enabled_flag = 'Y' AND user_id >=10 AND user_id <=15;
EXPLAIN SELECT * FROM t_user WHERE enabled_flag = 'Y' AND user_id IN(1,2);
7.非独立索引素索引，索引失效，导致全盘扫描 All
EXPLAIN SELECT * FROM t_user WHERE enabled_flag = 'Y' AND user_name LIKE '%李%';
8.索引覆盖
EXPLAIN SELECT user_name FROM t_user WHERE enabled_flag = 'Y' AND user_name LIKE '李';
9.type类型对应为SUBQUERY-子查询

三、子查询

1.子查询分类：
(1).相关子查询
 执行依赖于外部查询的数据。外部查询返回一行 ，子查询就执行一次。（对于该select，里面的子select会重复很多次执行）
EXPLAIN SELECT u.user_name,(SELECT r.role_name FROM t_role r WHERE r.role_id = ru.role_id) FROM t_user u,t_user_role ru WHERE u.user_id = ru.user_id; 
(2).非相关子查询
 独立于外部查询的子查询。子查询总共执行一次，执行完毕后后将值传递给外部查询。
EXPLAIN SELECT u.user_name,r.role_name FROM (SELECT ru.role_id,ru.user_id FROM t_user_role ru) t,t_role r,t_user u WHERE  t.role_id = r.role_id AND t.user_id = u.user_id;
2.子查询的7中类型
(1).Where子查询
指把内部查询的结果作为外层查询的比较条件
(2).From子查询
把内层的查询结果当成临时表，供外层sql再次查询
(3).IN子查询
内层查询语句仅返回一个数据列，这个数据列的值将供外层查询语句进行比较。
(4).exists子查询
把外层的查询结果，拿到内层，看内层是否成立，简单来说后面的返回true,外层（也就是前面的语句）才会执行，否则不执行。exist后面的子查询是相关子查询，不会返回列表中的值。
执行顺序：
a.首先执行一次外部查询
b.对于外部查询中的每一行分别执行一次子查询，而且每次执行子查询时都会引用外部查询中当前行的值。
c.使用子查询的结果来确定外部查询的结果集。如果外部查询返回100行，SQL就将执行101次查询，一次执行外部查询，然后为外部查询返回的每一行执行一次子查询。
EXISTS与IN的使用效率的问题，通常情况下采用exists要比in效率高，因为IN不走索引，但要看实际情况具体使用：IN适合于外表大而内表小的情况；EXISTS适合于外表小而内表大的情况。
(5).any子查询
只要满足内层子查询中的任意一个比较条件，就返回一个结果作为外层查询条件
(6).all子查询
内层子查询返回的结果需同时满足所有内层查询条件

四、案例
1.求查出挂科2门及以上同学的平均分
方法1：
EXPLAIN SELECT m.name AS '姓名',AVG(m.score) AS '平均分' FROM t_student AS m WHERE m.name IN (
		SELECT tmp.name FROM
			(
				SELECT t.name,SUM(score < 60) AS count FROM t_student t GROUP BY t.name
			 ) AS tmp
		WHERE
			tmp.count >= 2
	)
GROUP BY
	m.name;
方法2：
select name ,avg(score) as '平均分' from t_student where name in(select name from (select name,count(*) as gk from t_student where score<60 group by name having gk>=2)as tmp)
group by name;


2.分组排序
错误方式：
SELECT * FROM t_user u WHERE u.enabled_flag = 'Y' GROUP BY u.user_name ORDER BY u.creation_date DESC;
正确方式
方法1：
SELECT
	*
FROM
	t_user m
WHERE
	(
		SELECT
			COUNT(*)
		FROM
			t_user n
		WHERE
			m.user_name = n.user_name
		AND m.creation_date > n.creation_date
	) < 1;

EXPLAIN SELECT
	*
FROM
	(SELECT * from t_user t WHERE t.enabled_flag = 'Y') m
WHERE
	(
		SELECT
			COUNT(*)
		FROM
			(SELECT * from t_user t WHERE t.enabled_flag = 'Y') n
		WHERE
			m.user_name = n.user_name
		AND m.creation_date < n.creation_date
	) < 2
ORDER BY
	user_name,
	creation_date DESC;

方法2：
row_number() OVER ( PARTITION BY COL1 ORDER BY COL2) 表示根据COL1分组，在分组内部根据 COL2排序，而此函数计算的值就表示每组内部排序后的顺序编号（组内连续的唯一的).
与rownum的区别在于：使用rownum进行排序的时候是先对结果集加入伪列rownum然后再进行排序，而此函数在包含排序从句后是先排序再计算行号码
EXPLAIN SELECT n.user_id,n.user_name,n.enabled_flag,n.creation_date,n.n FROM (SELECT user_id,user_name,enabled_flag,creation_date, row_number() OVER (PARTITION BY user_name ORDER BY creation_date DESC) as n FROM t_user ) as n WHERE n.n<=2;

-- 关联查询的顺序
-- 1.默认按优化后的顺序执行
  EXPLAIN SELECT u.user_id,u.user_name,r.role_id,r.role_name,r.role_desc FROM t_user u INNER JOIN t_user_role ur ON u.user_id = ur.user_id INNER JOIN t_role r ON ur.role_id = r.role_id WHERE u.enabled_flag = 'Y' AND ur.enabled_flag = 'Y' AND r.enabled_flag = 'Y';
-- 2.STRAIGHT_JOIN 按指定的连接顺序执行
  EXPLAIN SELECT STRAIGHT_JOIN u.user_id,u.user_name,r.role_id,r.role_name,r.role_desc FROM t_user u INNER JOIN t_user_role ur ON u.user_id = ur.user_id INNER JOIN t_role r ON ur.role_id = r.role_id WHERE u.enabled_flag = 'Y' AND ur.enabled_flag = 'Y' AND r.enabled_flag = 'Y';

USING 
USING语法简化JOIN ON --- using(id) 等价于 on a.id=b.id



