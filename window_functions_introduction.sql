select
  название_функции(СТОЛБЕЦ_ДЛЯ_ВЫЧИСЛЕНИЙ) 
  over (partition by СТОЛБЕЦ_ДЛЯ_ГРУППИРОВКИ order by СТОЛБЕЦ_ДЛЯ_СОРТИРОВКИ)
from employees
;


select
  FIRST_NAME, LAST_NAME, JOB_ID, SALARY,
  ROW_NUMBER() OVER (PARTITION BY JOB_ID ORDER BY SALARY) as ORDER_SALARY
from employees
;


select
  FIRST_NAME, LAST_NAME, JOB_ID, SALARY,
  ROW_NUMBER() OVER (PARTITION BY JOB_ID ORDER BY SALARY DESC) as ORDER_SALARY
from employees
;


select
  FIRST_NAME, LAST_NAME, JOB_ID, SALARY,
  ROW_NUMBER() OVER (PARTITION BY JOB_ID ORDER BY SALARY) as FN_ROW_NUMBER,
  RANK() OVER (PARTITION BY JOB_ID ORDER BY SALARY) as FN_RANK,
  DENSE_RANK() OVER (PARTITION BY JOB_ID ORDER BY SALARY) as FN_DENSE_RANK
from employees
;


select
  FIRST_NAME, LAST_NAME, JOB_ID, SALARY,
  NTILE(10) OVER (PARTITION BY JOB_ID ORDER BY SALARY) as FN_NTILE
from 
  (
    select * from employees
    where SALARY between 6000 and 7300
    and JOB_ID = 'SA_REP'
  )
;

