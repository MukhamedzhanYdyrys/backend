--
-- PostgreSQL database dump
--

-- Dumped from database version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.11 (Ubuntu 14.11-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_score_for_role(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_score_for_role(my_role_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare score int;
BEGIN
    select sum(ss.points) + 100 as score
    into score
    from companies_role cr
         inner join scores_score ss on ss.role_id = cr.id
    where
        cr.id=my_role_id
        and
        extract (month from ss.created_at at time zone 'Asia/Almaty') = extract (month from current_date at time zone 'Asia/Almaty')
    group by cr.id;
    if score is null then
        score=100;
    end if;
    return score;
end $$;


ALTER FUNCTION public.get_score_for_role(my_role_id bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO damir;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO damir;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO damir;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO damir;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO damir;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO damir;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: auth_user_otptoken; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_otptoken (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    token character varying(32) NOT NULL,
    code character varying(8) NOT NULL,
    phone_number character varying(32) NOT NULL,
    verified boolean NOT NULL,
    action character varying(50) NOT NULL,
    company_id bigint,
    user_id bigint
);


ALTER TABLE public.auth_user_otptoken OWNER TO damir;

--
-- Name: auth_user_otptoken_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_otptoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_otptoken_id_seq OWNER TO damir;

--
-- Name: auth_user_otptoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_otptoken_id_seq OWNED BY public.auth_user_otptoken.id;


--
-- Name: auth_user_pendinguser; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_pendinguser (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    middle_name character varying(50) NOT NULL,
    email character varying(70) NOT NULL,
    phone_number character varying(32) NOT NULL,
    password_hash character varying(128) NOT NULL,
    avatar character varying(100),
    department_id bigint NOT NULL
);


ALTER TABLE public.auth_user_pendinguser OWNER TO damir;

--
-- Name: auth_user_pendinguser_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_pendinguser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_pendinguser_id_seq OWNER TO damir;

--
-- Name: auth_user_pendinguser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_pendinguser_id_seq OWNED BY public.auth_user_pendinguser.id;


--
-- Name: auth_user_resetpasswordtoken; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_resetpasswordtoken (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    token character varying(32) NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.auth_user_resetpasswordtoken OWNER TO damir;

--
-- Name: auth_user_resetpasswordtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_resetpasswordtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_resetpasswordtoken_id_seq OWNER TO damir;

--
-- Name: auth_user_resetpasswordtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_resetpasswordtoken_id_seq OWNED BY public.auth_user_resetpasswordtoken.id;


--
-- Name: auth_user_user; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_user (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    type smallint NOT NULL,
    email character varying(70) NOT NULL,
    email_new character varying(70),
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    middle_name character varying(50) NOT NULL,
    phone_number character varying(15) NOT NULL,
    avatar character varying(100),
    is_superuser boolean NOT NULL,
    is_admin boolean NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    assistant_type smallint NOT NULL,
    language character varying(10) NOT NULL,
    owner_id bigint,
    selected_company_id bigint,
    CONSTRAINT auth_user_user_assistant_type_check CHECK ((assistant_type >= 0)),
    CONSTRAINT auth_user_user_type_check CHECK ((type >= 0))
);


ALTER TABLE public.auth_user_user OWNER TO damir;

--
-- Name: auth_user_user_groups; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_groups OWNER TO damir;

--
-- Name: auth_user_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_groups_id_seq OWNER TO damir;

--
-- Name: auth_user_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_user_groups_id_seq OWNED BY public.auth_user_user_groups.id;


--
-- Name: auth_user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_id_seq OWNER TO damir;

--
-- Name: auth_user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_user_id_seq OWNED BY public.auth_user_user.id;


--
-- Name: auth_user_user_user_permissions; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.auth_user_user_user_permissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_user_permissions OWNER TO damir;

--
-- Name: auth_user_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.auth_user_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_user_permissions_id_seq OWNER TO damir;

--
-- Name: auth_user_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.auth_user_user_user_permissions_id_seq OWNED BY public.auth_user_user_user_permissions.id;


--
-- Name: checklist_checklist; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_checklist (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    start_date date,
    timezone character varying(64) NOT NULL,
    executor_reward integer NOT NULL,
    executor_penalty_late integer NOT NULL,
    executor_penalty_not_completed integer NOT NULL,
    inspector_reward integer NOT NULL,
    inspector_penalty_late integer NOT NULL,
    inspector_penalty_not_completed integer NOT NULL,
    company_id bigint NOT NULL,
    department_id bigint,
    CONSTRAINT checklist_checklist_executor_penalty_late_check CHECK ((executor_penalty_late >= 0)),
    CONSTRAINT checklist_checklist_executor_penalty_not_completed_check CHECK ((executor_penalty_not_completed >= 0)),
    CONSTRAINT checklist_checklist_executor_reward_check CHECK ((executor_reward >= 0)),
    CONSTRAINT checklist_checklist_inspector_penalty_late_check CHECK ((inspector_penalty_late >= 0)),
    CONSTRAINT checklist_checklist_inspector_penalty_not_completed_check CHECK ((inspector_penalty_not_completed >= 0)),
    CONSTRAINT checklist_checklist_inspector_reward_check CHECK ((inspector_reward >= 0))
);


ALTER TABLE public.checklist_checklist OWNER TO damir;

--
-- Name: checklist_checklist_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_checklist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_checklist_id_seq OWNER TO damir;

--
-- Name: checklist_checklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_checklist_id_seq OWNED BY public.checklist_checklist.id;


--
-- Name: checklist_checklistassign; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_checklistassign (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    type integer NOT NULL,
    checklist_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.checklist_checklistassign OWNER TO damir;

--
-- Name: checklist_checklistassign_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_checklistassign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_checklistassign_id_seq OWNER TO damir;

--
-- Name: checklist_checklistassign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_checklistassign_id_seq OWNED BY public.checklist_checklistassign.id;


--
-- Name: checklist_checklistcomplete; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_checklistcomplete (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    date date NOT NULL,
    points integer NOT NULL,
    status integer NOT NULL,
    checklist_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.checklist_checklistcomplete OWNER TO damir;

--
-- Name: checklist_checklistcomplete_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_checklistcomplete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_checklistcomplete_id_seq OWNER TO damir;

--
-- Name: checklist_checklistcomplete_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_checklistcomplete_id_seq OWNED BY public.checklist_checklistcomplete.id;


--
-- Name: checklist_checklistschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_checklistschedule (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    week_day integer NOT NULL,
    time_from time without time zone,
    time_to time without time zone,
    notified_day date,
    checklist_id bigint NOT NULL
);


ALTER TABLE public.checklist_checklistschedule OWNER TO damir;

--
-- Name: checklist_checklistschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_checklistschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_checklistschedule_id_seq OWNER TO damir;

--
-- Name: checklist_checklistschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_checklistschedule_id_seq OWNED BY public.checklist_checklistschedule.id;


--
-- Name: checklist_file; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_file (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    file_name text NOT NULL,
    file_size bigint NOT NULL,
    local_file character varying(100),
    s3_url text NOT NULL,
    uploaded_by_id bigint,
    CONSTRAINT checklist_file_file_size_check CHECK ((file_size >= 0))
);


ALTER TABLE public.checklist_file OWNER TO damir;

--
-- Name: checklist_file_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_file_id_seq OWNER TO damir;

--
-- Name: checklist_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_file_id_seq OWNED BY public.checklist_file.id;


--
-- Name: checklist_task; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_task (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    group_id bigint NOT NULL
);


ALTER TABLE public.checklist_task OWNER TO damir;

--
-- Name: checklist_task_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_task_id_seq OWNER TO damir;

--
-- Name: checklist_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_task_id_seq OWNED BY public.checklist_task.id;


--
-- Name: checklist_taskcheck; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_taskcheck (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    date date NOT NULL,
    task_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.checklist_taskcheck OWNER TO damir;

--
-- Name: checklist_taskcheck_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_taskcheck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_taskcheck_id_seq OWNER TO damir;

--
-- Name: checklist_taskcheck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_taskcheck_id_seq OWNED BY public.checklist_taskcheck.id;


--
-- Name: checklist_taskfile; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_taskfile (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    file_id bigint NOT NULL,
    task_id bigint NOT NULL
);


ALTER TABLE public.checklist_taskfile OWNER TO damir;

--
-- Name: checklist_taskfile_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_taskfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_taskfile_id_seq OWNER TO damir;

--
-- Name: checklist_taskfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_taskfile_id_seq OWNED BY public.checklist_taskfile.id;


--
-- Name: checklist_taskgroup; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.checklist_taskgroup (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    checkbox boolean NOT NULL,
    checklist_id bigint NOT NULL
);


ALTER TABLE public.checklist_taskgroup OWNER TO damir;

--
-- Name: checklist_taskgroup_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.checklist_taskgroup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checklist_taskgroup_id_seq OWNER TO damir;

--
-- Name: checklist_taskgroup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.checklist_taskgroup_id_seq OWNED BY public.checklist_taskgroup.id;


--
-- Name: companies_company; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_company (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    invite_code character varying(10) NOT NULL,
    years_of_work integer NOT NULL,
    max_employees_qty integer NOT NULL,
    is_active boolean NOT NULL,
    is_deleted boolean NOT NULL,
    is_main boolean NOT NULL,
    owner_id bigint
);


ALTER TABLE public.companies_company OWNER TO damir;

--
-- Name: companies_company_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_company_id_seq OWNER TO damir;

--
-- Name: companies_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_company_id_seq OWNED BY public.companies_company.id;


--
-- Name: companies_department; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_department (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    is_hr boolean NOT NULL,
    timezone character varying(64) NOT NULL,
    start_inaccuracy integer NOT NULL,
    company_id bigint NOT NULL,
    head_of_department_id bigint,
    CONSTRAINT companies_department_start_inaccuracy_check CHECK ((start_inaccuracy >= 0))
);


ALTER TABLE public.companies_department OWNER TO damir;

--
-- Name: companies_department_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_department_id_seq OWNER TO damir;

--
-- Name: companies_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_department_id_seq OWNED BY public.companies_department.id;


--
-- Name: companies_department_zones; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_department_zones (
    id bigint NOT NULL,
    department_id bigint NOT NULL,
    zone_id bigint NOT NULL
);


ALTER TABLE public.companies_department_zones OWNER TO damir;

--
-- Name: companies_department_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_department_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_department_zones_id_seq OWNER TO damir;

--
-- Name: companies_department_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_department_zones_id_seq OWNED BY public.companies_department_zones.id;


--
-- Name: companies_role; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_role (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    role integer NOT NULL,
    title character varying(200) NOT NULL,
    grade integer NOT NULL,
    checkout_any_time boolean NOT NULL,
    in_zone boolean NOT NULL,
    checkout_time integer NOT NULL,
    company_id bigint NOT NULL,
    department_id bigint,
    user_id bigint NOT NULL,
    CONSTRAINT companies_role_checkout_time_check CHECK ((checkout_time >= 0))
);


ALTER TABLE public.companies_role OWNER TO damir;

--
-- Name: companies_role_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_role_id_seq OWNER TO damir;

--
-- Name: companies_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_role_id_seq OWNED BY public.companies_role.id;


--
-- Name: companies_zone; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_zone (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    address character varying(255) NOT NULL,
    latitude numeric(22,6) NOT NULL,
    longitude numeric(22,6) NOT NULL,
    radius integer NOT NULL,
    company_id bigint NOT NULL
);


ALTER TABLE public.companies_zone OWNER TO damir;

--
-- Name: companies_zone_employees; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.companies_zone_employees (
    id bigint NOT NULL,
    zone_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.companies_zone_employees OWNER TO damir;

--
-- Name: companies_zone_employees_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_zone_employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_zone_employees_id_seq OWNER TO damir;

--
-- Name: companies_zone_employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_zone_employees_id_seq OWNED BY public.companies_zone_employees.id;


--
-- Name: companies_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.companies_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_zone_id_seq OWNER TO damir;

--
-- Name: companies_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.companies_zone_id_seq OWNED BY public.companies_zone.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO damir;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO damir;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_celery_beat_clockedschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_clockedschedule (
    id integer NOT NULL,
    clocked_time timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_clockedschedule OWNER TO damir;

--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_beat_clockedschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_beat_clockedschedule_id_seq OWNER TO damir;

--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_beat_clockedschedule_id_seq OWNED BY public.django_celery_beat_clockedschedule.id;


--
-- Name: django_celery_beat_crontabschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_crontabschedule (
    id integer NOT NULL,
    minute character varying(240) NOT NULL,
    hour character varying(96) NOT NULL,
    day_of_week character varying(64) NOT NULL,
    day_of_month character varying(124) NOT NULL,
    month_of_year character varying(64) NOT NULL,
    timezone character varying(63) NOT NULL
);


ALTER TABLE public.django_celery_beat_crontabschedule OWNER TO damir;

--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_beat_crontabschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_beat_crontabschedule_id_seq OWNER TO damir;

--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_beat_crontabschedule_id_seq OWNED BY public.django_celery_beat_crontabschedule.id;


--
-- Name: django_celery_beat_intervalschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_intervalschedule (
    id integer NOT NULL,
    every integer NOT NULL,
    period character varying(24) NOT NULL
);


ALTER TABLE public.django_celery_beat_intervalschedule OWNER TO damir;

--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_beat_intervalschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_beat_intervalschedule_id_seq OWNER TO damir;

--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_beat_intervalschedule_id_seq OWNED BY public.django_celery_beat_intervalschedule.id;


--
-- Name: django_celery_beat_periodictask; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_periodictask (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    task character varying(200) NOT NULL,
    args text NOT NULL,
    kwargs text NOT NULL,
    queue character varying(200),
    exchange character varying(200),
    routing_key character varying(200),
    expires timestamp with time zone,
    enabled boolean NOT NULL,
    last_run_at timestamp with time zone,
    total_run_count integer NOT NULL,
    date_changed timestamp with time zone NOT NULL,
    description text NOT NULL,
    crontab_id integer,
    interval_id integer,
    solar_id integer,
    one_off boolean NOT NULL,
    start_time timestamp with time zone,
    priority integer,
    headers text NOT NULL,
    clocked_id integer,
    expire_seconds integer,
    CONSTRAINT django_celery_beat_periodictask_expire_seconds_check CHECK ((expire_seconds >= 0)),
    CONSTRAINT django_celery_beat_periodictask_priority_check CHECK ((priority >= 0)),
    CONSTRAINT django_celery_beat_periodictask_total_run_count_check CHECK ((total_run_count >= 0))
);


ALTER TABLE public.django_celery_beat_periodictask OWNER TO damir;

--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_beat_periodictask_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_beat_periodictask_id_seq OWNER TO damir;

--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_beat_periodictask_id_seq OWNED BY public.django_celery_beat_periodictask.id;


--
-- Name: django_celery_beat_periodictasks; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_periodictasks (
    ident smallint NOT NULL,
    last_update timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_periodictasks OWNER TO damir;

--
-- Name: django_celery_beat_solarschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_beat_solarschedule (
    id integer NOT NULL,
    event character varying(24) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL
);


ALTER TABLE public.django_celery_beat_solarschedule OWNER TO damir;

--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_beat_solarschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_beat_solarschedule_id_seq OWNER TO damir;

--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_beat_solarschedule_id_seq OWNED BY public.django_celery_beat_solarschedule.id;


--
-- Name: django_celery_results_chordcounter; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_results_chordcounter (
    id integer NOT NULL,
    group_id character varying(255) NOT NULL,
    sub_tasks text NOT NULL,
    count integer NOT NULL,
    CONSTRAINT django_celery_results_chordcounter_count_check CHECK ((count >= 0))
);


ALTER TABLE public.django_celery_results_chordcounter OWNER TO damir;

--
-- Name: django_celery_results_chordcounter_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_results_chordcounter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_results_chordcounter_id_seq OWNER TO damir;

--
-- Name: django_celery_results_chordcounter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_results_chordcounter_id_seq OWNED BY public.django_celery_results_chordcounter.id;


--
-- Name: django_celery_results_groupresult; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_results_groupresult (
    id integer NOT NULL,
    group_id character varying(255) NOT NULL,
    date_created timestamp with time zone NOT NULL,
    date_done timestamp with time zone NOT NULL,
    content_type character varying(128) NOT NULL,
    content_encoding character varying(64) NOT NULL,
    result text
);


ALTER TABLE public.django_celery_results_groupresult OWNER TO damir;

--
-- Name: django_celery_results_groupresult_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_results_groupresult_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_results_groupresult_id_seq OWNER TO damir;

--
-- Name: django_celery_results_groupresult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_results_groupresult_id_seq OWNED BY public.django_celery_results_groupresult.id;


--
-- Name: django_celery_results_taskresult; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_celery_results_taskresult (
    id integer NOT NULL,
    task_id character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    content_type character varying(128) NOT NULL,
    content_encoding character varying(64) NOT NULL,
    result text,
    date_done timestamp with time zone NOT NULL,
    traceback text,
    meta text,
    task_args text,
    task_kwargs text,
    task_name character varying(255),
    worker character varying(100),
    date_created timestamp with time zone NOT NULL,
    periodic_task_name character varying(255)
);


ALTER TABLE public.django_celery_results_taskresult OWNER TO damir;

--
-- Name: django_celery_results_taskresult_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_celery_results_taskresult_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_celery_results_taskresult_id_seq OWNER TO damir;

--
-- Name: django_celery_results_taskresult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_celery_results_taskresult_id_seq OWNED BY public.django_celery_results_taskresult.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO damir;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO damir;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_db_logger_statuslog; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_db_logger_statuslog (
    id integer NOT NULL,
    logger_name character varying(100) NOT NULL,
    level smallint NOT NULL,
    msg text NOT NULL,
    trace text,
    create_datetime timestamp with time zone NOT NULL,
    CONSTRAINT django_db_logger_statuslog_level_check CHECK ((level >= 0))
);


ALTER TABLE public.django_db_logger_statuslog OWNER TO damir;

--
-- Name: django_db_logger_statuslog_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_db_logger_statuslog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_db_logger_statuslog_id_seq OWNER TO damir;

--
-- Name: django_db_logger_statuslog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_db_logger_statuslog_id_seq OWNED BY public.django_db_logger_statuslog.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO damir;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO damir;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO damir;

--
-- Name: fcm_django_fcmdevice; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.fcm_django_fcmdevice (
    id integer NOT NULL,
    name character varying(255),
    active boolean NOT NULL,
    date_created timestamp with time zone,
    device_id character varying(255),
    registration_id text NOT NULL,
    type character varying(10) NOT NULL,
    user_id bigint
);


ALTER TABLE public.fcm_django_fcmdevice OWNER TO damir;

--
-- Name: fcm_django_fcmdevice_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.fcm_django_fcmdevice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fcm_django_fcmdevice_id_seq OWNER TO damir;

--
-- Name: fcm_django_fcmdevice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.fcm_django_fcmdevice_id_seq OWNED BY public.fcm_django_fcmdevice.id;


--
-- Name: scores_reason; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.scores_reason (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(255) NOT NULL,
    type integer NOT NULL,
    score smallint NOT NULL,
    company_id bigint NOT NULL
);


ALTER TABLE public.scores_reason OWNER TO damir;

--
-- Name: scores_reason_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.scores_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scores_reason_id_seq OWNER TO damir;

--
-- Name: scores_reason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.scores_reason_id_seq OWNED BY public.scores_reason.id;


--
-- Name: scores_score; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.scores_score (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    reason_type integer NOT NULL,
    name character varying(255) NOT NULL,
    points smallint NOT NULL,
    created_by_id bigint,
    role_id bigint NOT NULL
);


ALTER TABLE public.scores_score OWNER TO damir;

--
-- Name: scores_score_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.scores_score_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scores_score_id_seq OWNER TO damir;

--
-- Name: scores_score_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.scores_score_id_seq OWNED BY public.scores_score.id;


--
-- Name: timesheet_departmentschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.timesheet_departmentschedule (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    week_day integer NOT NULL,
    time_from time without time zone NOT NULL,
    time_to time without time zone NOT NULL,
    department_id bigint NOT NULL
);


ALTER TABLE public.timesheet_departmentschedule OWNER TO damir;

--
-- Name: timesheet_departmentschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.timesheet_departmentschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timesheet_departmentschedule_id_seq OWNER TO damir;

--
-- Name: timesheet_departmentschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.timesheet_departmentschedule_id_seq OWNED BY public.timesheet_departmentschedule.id;


--
-- Name: timesheet_employeeschedule; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.timesheet_employeeschedule (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    time_from time without time zone NOT NULL,
    time_to time without time zone NOT NULL,
    is_night_shift boolean NOT NULL,
    is_remote boolean NOT NULL,
    week_day integer NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.timesheet_employeeschedule OWNER TO damir;

--
-- Name: timesheet_employeeschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.timesheet_employeeschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timesheet_employeeschedule_id_seq OWNER TO damir;

--
-- Name: timesheet_employeeschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.timesheet_employeeschedule_id_seq OWNED BY public.timesheet_employeeschedule.id;


--
-- Name: timesheet_timesheet; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.timesheet_timesheet (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    day date NOT NULL,
    device_id character varying(40) NOT NULL,
    check_in timestamp with time zone,
    check_out timestamp with time zone,
    time_from time without time zone,
    time_to time without time zone,
    comment text NOT NULL,
    debug_comment text NOT NULL,
    file character varying(100),
    status smallint NOT NULL,
    timezone character varying(64) NOT NULL,
    is_night_shift boolean NOT NULL,
    is_remote boolean NOT NULL,
    role_id bigint NOT NULL,
    CONSTRAINT timesheet_timesheet_status_check CHECK ((status >= 0))
);


ALTER TABLE public.timesheet_timesheet OWNER TO damir;

--
-- Name: timesheet_timesheet_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.timesheet_timesheet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timesheet_timesheet_id_seq OWNER TO damir;

--
-- Name: timesheet_timesheet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.timesheet_timesheet_id_seq OWNED BY public.timesheet_timesheet.id;


--
-- Name: token_blacklist_blacklistedtoken; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.token_blacklist_blacklistedtoken (
    id bigint NOT NULL,
    blacklisted_at timestamp with time zone NOT NULL,
    token_id bigint NOT NULL
);


ALTER TABLE public.token_blacklist_blacklistedtoken OWNER TO damir;

--
-- Name: token_blacklist_blacklistedtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.token_blacklist_blacklistedtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.token_blacklist_blacklistedtoken_id_seq OWNER TO damir;

--
-- Name: token_blacklist_blacklistedtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.token_blacklist_blacklistedtoken_id_seq OWNED BY public.token_blacklist_blacklistedtoken.id;


--
-- Name: token_blacklist_outstandingtoken; Type: TABLE; Schema: public; Owner: damir
--

CREATE TABLE public.token_blacklist_outstandingtoken (
    id bigint NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    user_id bigint,
    jti character varying(255) NOT NULL
);


ALTER TABLE public.token_blacklist_outstandingtoken OWNER TO damir;

--
-- Name: token_blacklist_outstandingtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: damir
--

CREATE SEQUENCE public.token_blacklist_outstandingtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.token_blacklist_outstandingtoken_id_seq OWNER TO damir;

--
-- Name: token_blacklist_outstandingtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: damir
--

ALTER SEQUENCE public.token_blacklist_outstandingtoken_id_seq OWNED BY public.token_blacklist_outstandingtoken.id;


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: auth_user_otptoken id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_otptoken ALTER COLUMN id SET DEFAULT nextval('public.auth_user_otptoken_id_seq'::regclass);


--
-- Name: auth_user_pendinguser id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_pendinguser ALTER COLUMN id SET DEFAULT nextval('public.auth_user_pendinguser_id_seq'::regclass);


--
-- Name: auth_user_resetpasswordtoken id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_resetpasswordtoken ALTER COLUMN id SET DEFAULT nextval('public.auth_user_resetpasswordtoken_id_seq'::regclass);


--
-- Name: auth_user_user id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_id_seq'::regclass);


--
-- Name: auth_user_user_groups id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_groups_id_seq'::regclass);


--
-- Name: auth_user_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_user_permissions_id_seq'::regclass);


--
-- Name: checklist_checklist id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklist ALTER COLUMN id SET DEFAULT nextval('public.checklist_checklist_id_seq'::regclass);


--
-- Name: checklist_checklistassign id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistassign ALTER COLUMN id SET DEFAULT nextval('public.checklist_checklistassign_id_seq'::regclass);


--
-- Name: checklist_checklistcomplete id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistcomplete ALTER COLUMN id SET DEFAULT nextval('public.checklist_checklistcomplete_id_seq'::regclass);


--
-- Name: checklist_checklistschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistschedule ALTER COLUMN id SET DEFAULT nextval('public.checklist_checklistschedule_id_seq'::regclass);


--
-- Name: checklist_file id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_file ALTER COLUMN id SET DEFAULT nextval('public.checklist_file_id_seq'::regclass);


--
-- Name: checklist_task id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_task ALTER COLUMN id SET DEFAULT nextval('public.checklist_task_id_seq'::regclass);


--
-- Name: checklist_taskcheck id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskcheck ALTER COLUMN id SET DEFAULT nextval('public.checklist_taskcheck_id_seq'::regclass);


--
-- Name: checklist_taskfile id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskfile ALTER COLUMN id SET DEFAULT nextval('public.checklist_taskfile_id_seq'::regclass);


--
-- Name: checklist_taskgroup id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskgroup ALTER COLUMN id SET DEFAULT nextval('public.checklist_taskgroup_id_seq'::regclass);


--
-- Name: companies_company id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_company ALTER COLUMN id SET DEFAULT nextval('public.companies_company_id_seq'::regclass);


--
-- Name: companies_department id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department ALTER COLUMN id SET DEFAULT nextval('public.companies_department_id_seq'::regclass);


--
-- Name: companies_department_zones id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department_zones ALTER COLUMN id SET DEFAULT nextval('public.companies_department_zones_id_seq'::regclass);


--
-- Name: companies_role id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role ALTER COLUMN id SET DEFAULT nextval('public.companies_role_id_seq'::regclass);


--
-- Name: companies_zone id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone ALTER COLUMN id SET DEFAULT nextval('public.companies_zone_id_seq'::regclass);


--
-- Name: companies_zone_employees id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone_employees ALTER COLUMN id SET DEFAULT nextval('public.companies_zone_employees_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_celery_beat_clockedschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_clockedschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_crontabschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_crontabschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_intervalschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_intervalschedule_id_seq'::regclass);


--
-- Name: django_celery_beat_periodictask id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_periodictask_id_seq'::regclass);


--
-- Name: django_celery_beat_solarschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule ALTER COLUMN id SET DEFAULT nextval('public.django_celery_beat_solarschedule_id_seq'::regclass);


--
-- Name: django_celery_results_chordcounter id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_chordcounter ALTER COLUMN id SET DEFAULT nextval('public.django_celery_results_chordcounter_id_seq'::regclass);


--
-- Name: django_celery_results_groupresult id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_groupresult ALTER COLUMN id SET DEFAULT nextval('public.django_celery_results_groupresult_id_seq'::regclass);


--
-- Name: django_celery_results_taskresult id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_taskresult ALTER COLUMN id SET DEFAULT nextval('public.django_celery_results_taskresult_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_db_logger_statuslog id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_db_logger_statuslog ALTER COLUMN id SET DEFAULT nextval('public.django_db_logger_statuslog_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: fcm_django_fcmdevice id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.fcm_django_fcmdevice ALTER COLUMN id SET DEFAULT nextval('public.fcm_django_fcmdevice_id_seq'::regclass);


--
-- Name: scores_reason id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_reason ALTER COLUMN id SET DEFAULT nextval('public.scores_reason_id_seq'::regclass);


--
-- Name: scores_score id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_score ALTER COLUMN id SET DEFAULT nextval('public.scores_score_id_seq'::regclass);


--
-- Name: timesheet_departmentschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_departmentschedule ALTER COLUMN id SET DEFAULT nextval('public.timesheet_departmentschedule_id_seq'::regclass);


--
-- Name: timesheet_employeeschedule id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_employeeschedule ALTER COLUMN id SET DEFAULT nextval('public.timesheet_employeeschedule_id_seq'::regclass);


--
-- Name: timesheet_timesheet id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_timesheet ALTER COLUMN id SET DEFAULT nextval('public.timesheet_timesheet_id_seq'::regclass);


--
-- Name: token_blacklist_blacklistedtoken id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_blacklistedtoken ALTER COLUMN id SET DEFAULT nextval('public.token_blacklist_blacklistedtoken_id_seq'::regclass);


--
-- Name: token_blacklist_outstandingtoken id; Type: DEFAULT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_outstandingtoken ALTER COLUMN id SET DEFAULT nextval('public.token_blacklist_outstandingtoken_id_seq'::regclass);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add content type	4	add_contenttype
14	Can change content type	4	change_contenttype
15	Can delete content type	4	delete_contenttype
16	Can view content type	4	view_contenttype
17	Can add session	5	add_session
18	Can change session	5	change_session
19	Can delete session	5	delete_session
20	Can view session	5	view_session
21	Can add FCM device	6	add_fcmdevice
22	Can change FCM device	6	change_fcmdevice
23	Can delete FCM device	6	delete_fcmdevice
24	Can view FCM device	6	view_fcmdevice
25	Can add Logging	7	add_statuslog
26	Can change Logging	7	change_statuslog
27	Can delete Logging	7	delete_statuslog
28	Can view Logging	7	view_statuslog
29	Can add crontab	8	add_crontabschedule
30	Can change crontab	8	change_crontabschedule
31	Can delete crontab	8	delete_crontabschedule
32	Can view crontab	8	view_crontabschedule
33	Can add interval	9	add_intervalschedule
34	Can change interval	9	change_intervalschedule
35	Can delete interval	9	delete_intervalschedule
36	Can view interval	9	view_intervalschedule
37	Can add periodic task	10	add_periodictask
38	Can change periodic task	10	change_periodictask
39	Can delete periodic task	10	delete_periodictask
40	Can view periodic task	10	view_periodictask
41	Can add periodic tasks	11	add_periodictasks
42	Can change periodic tasks	11	change_periodictasks
43	Can delete periodic tasks	11	delete_periodictasks
44	Can view periodic tasks	11	view_periodictasks
45	Can add solar event	12	add_solarschedule
46	Can change solar event	12	change_solarschedule
47	Can delete solar event	12	delete_solarschedule
48	Can view solar event	12	view_solarschedule
49	Can add clocked	13	add_clockedschedule
50	Can change clocked	13	change_clockedschedule
51	Can delete clocked	13	delete_clockedschedule
52	Can view clocked	13	view_clockedschedule
53	Can add task result	14	add_taskresult
54	Can change task result	14	change_taskresult
55	Can delete task result	14	delete_taskresult
56	Can view task result	14	view_taskresult
57	Can add chord counter	15	add_chordcounter
58	Can change chord counter	15	change_chordcounter
59	Can delete chord counter	15	delete_chordcounter
60	Can view chord counter	15	view_chordcounter
61	Can add group result	16	add_groupresult
62	Can change group result	16	change_groupresult
63	Can delete group result	16	delete_groupresult
64	Can view group result	16	view_groupresult
65	Can add blacklisted token	17	add_blacklistedtoken
66	Can change blacklisted token	17	change_blacklistedtoken
67	Can delete blacklisted token	17	delete_blacklistedtoken
68	Can view blacklisted token	17	view_blacklistedtoken
69	Can add outstanding token	18	add_outstandingtoken
70	Can change outstanding token	18	change_outstandingtoken
71	Can delete outstanding token	18	delete_outstandingtoken
72	Can view outstanding token	18	view_outstandingtoken
73	Can add Пользователь	19	add_user
74	Can change Пользователь	19	change_user
75	Can delete Пользователь	19	delete_user
76	Can view Пользователь	19	view_user
77	Can add otp token	20	add_otptoken
78	Can change otp token	20	change_otptoken
79	Can delete otp token	20	delete_otptoken
80	Can view otp token	20	view_otptoken
81	Can add pending user	21	add_pendinguser
82	Can change pending user	21	change_pendinguser
83	Can delete pending user	21	delete_pendinguser
84	Can view pending user	21	view_pendinguser
85	Can add reset password token	22	add_resetpasswordtoken
86	Can change reset password token	22	change_resetpasswordtoken
87	Can delete reset password token	22	delete_resetpasswordtoken
88	Can view reset password token	22	view_resetpasswordtoken
89	Can add company	23	add_company
90	Can change company	23	change_company
91	Can delete company	23	delete_company
92	Can view company	23	view_company
93	Can add department	24	add_department
94	Can change department	24	change_department
95	Can delete department	24	delete_department
96	Can view department	24	view_department
97	Can add role	25	add_role
98	Can change role	25	change_role
99	Can delete role	25	delete_role
100	Can view role	25	view_role
101	Can add zone	26	add_zone
102	Can change zone	26	change_zone
103	Can delete zone	26	delete_zone
104	Can view zone	26	view_zone
105	Can add time sheet	27	add_timesheet
106	Can change time sheet	27	change_timesheet
107	Can delete time sheet	27	delete_timesheet
108	Can view time sheet	27	view_timesheet
109	Can add employee schedule	28	add_employeeschedule
110	Can change employee schedule	28	change_employeeschedule
111	Can delete employee schedule	28	delete_employeeschedule
112	Can view employee schedule	28	view_employeeschedule
113	Can add department schedule	29	add_departmentschedule
114	Can change department schedule	29	change_departmentschedule
115	Can delete department schedule	29	delete_departmentschedule
116	Can view department schedule	29	view_departmentschedule
117	Can add score	30	add_score
118	Can change score	30	change_score
119	Can delete score	30	delete_score
120	Can view score	30	view_score
121	Can add reason	31	add_reason
122	Can change reason	31	change_reason
123	Can delete reason	31	delete_reason
124	Can view reason	31	view_reason
125	Can add checklist	32	add_checklist
126	Can change checklist	32	change_checklist
127	Can delete checklist	32	delete_checklist
128	Can view checklist	32	view_checklist
129	Can add file	33	add_file
130	Can change file	33	change_file
131	Can delete file	33	delete_file
132	Can view file	33	view_file
133	Can add task	34	add_task
134	Can change task	34	change_task
135	Can delete task	34	delete_task
136	Can view task	34	view_task
137	Can add task group	35	add_taskgroup
138	Can change task group	35	change_taskgroup
139	Can delete task group	35	delete_taskgroup
140	Can view task group	35	view_taskgroup
141	Can add task file	36	add_taskfile
142	Can change task file	36	change_taskfile
143	Can delete task file	36	delete_taskfile
144	Can view task file	36	view_taskfile
145	Can add task check	37	add_taskcheck
146	Can change task check	37	change_taskcheck
147	Can delete task check	37	delete_taskcheck
148	Can view task check	37	view_taskcheck
149	Can add checklist complete	38	add_checklistcomplete
150	Can change checklist complete	38	change_checklistcomplete
151	Can delete checklist complete	38	delete_checklistcomplete
152	Can view checklist complete	38	view_checklistcomplete
153	Can add checklist schedule	39	add_checklistschedule
154	Can change checklist schedule	39	change_checklistschedule
155	Can delete checklist schedule	39	delete_checklistschedule
156	Can view checklist schedule	39	view_checklistschedule
157	Can add checklist assign	40	add_checklistassign
158	Can change checklist assign	40	change_checklistassign
159	Can delete checklist assign	40	delete_checklistassign
160	Can view checklist assign	40	view_checklistassign
\.


--
-- Data for Name: auth_user_otptoken; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_otptoken (id, created_at, updated_at, token, code, phone_number, verified, action, company_id, user_id) FROM stdin;
\.


--
-- Data for Name: auth_user_pendinguser; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_pendinguser (id, created_at, updated_at, first_name, last_name, middle_name, email, phone_number, password_hash, avatar, department_id) FROM stdin;
1	2024-03-18 09:42:40.062368+00	2024-03-18 09:42:40.062391+00	Bekarys	Seitmukhamed		beka@mail.ru	+77472259455	pbkdf2_sha256$320000$N1Xt2sSg75j3RbZQbi1YHQ$JiziZ9/LP8xVWHq/nNmDTdQ+/ef6iZ+H6tOWaQIQ6BQ=		2
2	2024-03-18 11:37:15.928635+00	2024-03-18 11:37:15.928654+00	Bekarys	Seitmukhamed		beka@mail.ru	+77776665543	pbkdf2_sha256$320000$kbrfJaZRD0meQDyOjjuFqG$pwDTFrR00j9xipLp/Ylt7stnxz+kErNuiFuaBrW+IH4=	avatar/Screenshot_20240309-065533_WhatsApp.webp	2
\.


--
-- Data for Name: auth_user_resetpasswordtoken; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_resetpasswordtoken (id, created_at, updated_at, token, user_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_user (id, password, last_login, type, email, email_new, first_name, last_name, middle_name, phone_number, avatar, is_superuser, is_admin, is_staff, is_active, created_at, updated_at, assistant_type, language, owner_id, selected_company_id) FROM stdin;
2	pbkdf2_sha256$320000$QzrUfF657i1njKD6DT9Vbg$jv9+w0FU7ZnijXEr4ZF1bGto9d9Hq7cUYYmNhunxho4=	\N	1	owner@mail.ru	\N	Owner	Owner		+77776665544		f	f	f	t	2024-03-18 08:23:17.120617+00	2024-03-18 08:23:17.120625+00	0	ru	\N	2
1	pbkdf2_sha256$320000$vQjPbKMRFL5th4lc774L7D$wJmVS2fkv8Y/MftJ7aCHPI4MpR7QaFpq9mJiRuzSRQw=	2024-03-19 05:03:24.699831+00	0	admin@admin.kz	\N						t	f	t	t	2024-03-17 16:02:01.672001+00	2024-03-17 16:02:01.67202+00	0	ru	\N	\N
4	pbkdf2_sha256$320000$77N4jawP8qwCYnZvWUqa0T$0zBg8FtiDNjXZluZn2UDvtaXLfzIqJk2RYBv0SphWy8=	\N	3	jandos@mail.ru	\N	Jandos	Mokup		+78889990000		f	f	f	t	2024-03-19 06:34:07.5158+00	2024-03-19 06:34:07.51582+00	0	ru	2	2
5	pbkdf2_sha256$320000$hmR1cj24xDiDFT12hQAOX0$CCLg+hk90bhQOzNlICvU5G/5ctIajjsj4//Nai17erE=	\N	3	luni@mail.ru	\N	Luni	Popov		+78889990001		f	f	f	t	2024-03-19 06:34:59.163058+00	2024-03-19 06:34:59.163073+00	0	ru	2	2
6	pbkdf2_sha256$320000$2TXulWwnTR6g6AkUav6Nu8$9feWKEx8fZJ/utytTEymgfVSbPCAh3ICKU3oGVW061U=	\N	3	util@mail.ru	\N	Xoxlovich	Util		+78889990002		f	f	f	t	2024-03-19 06:35:36.062861+00	2024-03-19 06:35:36.062884+00	0	ru	2	2
7	pbkdf2_sha256$320000$wRlqXXYtSmzrapmC0NSxCz$LKZR4sF/JT+UyAF6GaWlvxYhbg+D59p96TGWRK9ok5g=	\N	3	ruchel@mail.ru	\N	Ruchel	Ouvil		+78889990003		f	f	f	t	2024-03-19 06:36:32.378975+00	2024-03-19 06:36:32.379012+00	0	ru	2	2
8	pbkdf2_sha256$320000$faEWKcsGvFAyHrYtNoBmK4$VO7/6Cw0rc9nnl/daAXfih+US/c3Ii0yjpHt+quxKp8=	\N	3	david@mail.ru	\N	Давид	Кусер		+78889990004		f	f	f	t	2024-03-19 06:44:08.1937+00	2024-03-19 06:44:08.19372+00	0	ru	2	2
3	pbkdf2_sha256$320000$r1qJ1oVuYSImwBKihuE83k$T9ePaAD4rh4czkah7XKEOX9Qh2r7xYH4udnGwz2p2BM=	\N	4	beka@mail.ru	\N	Beka	Bekov	kk	+77777777777	avatar/Screenshot_20240309-065533_WhatsApp_tB6EbnM.webp	f	f	f	t	2024-03-19 04:01:51.717925+00	2024-03-19 08:41:39.380634+00	0	en	2	2
\.


--
-- Data for Name: auth_user_user_groups; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.auth_user_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: checklist_checklist; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_checklist (id, created_at, updated_at, name, start_date, timezone, executor_reward, executor_penalty_late, executor_penalty_not_completed, inspector_reward, inspector_penalty_late, inspector_penalty_not_completed, company_id, department_id) FROM stdin;
\.


--
-- Data for Name: checklist_checklistassign; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_checklistassign (id, created_at, updated_at, type, checklist_id, user_id) FROM stdin;
\.


--
-- Data for Name: checklist_checklistcomplete; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_checklistcomplete (id, created_at, updated_at, date, points, status, checklist_id, user_id) FROM stdin;
\.


--
-- Data for Name: checklist_checklistschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_checklistschedule (id, created_at, updated_at, week_day, time_from, time_to, notified_day, checklist_id) FROM stdin;
\.


--
-- Data for Name: checklist_file; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_file (id, created_at, updated_at, file_name, file_size, local_file, s3_url, uploaded_by_id) FROM stdin;
\.


--
-- Data for Name: checklist_task; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_task (id, created_at, updated_at, name, group_id) FROM stdin;
\.


--
-- Data for Name: checklist_taskcheck; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_taskcheck (id, created_at, updated_at, date, task_id, user_id) FROM stdin;
\.


--
-- Data for Name: checklist_taskfile; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_taskfile (id, created_at, updated_at, file_id, task_id) FROM stdin;
\.


--
-- Data for Name: checklist_taskgroup; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.checklist_taskgroup (id, created_at, updated_at, name, checkbox, checklist_id) FROM stdin;
\.


--
-- Data for Name: companies_company; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_company (id, created_at, updated_at, name, invite_code, years_of_work, max_employees_qty, is_active, is_deleted, is_main, owner_id) FROM stdin;
2	2024-03-18 08:23:17.111285+00	2024-03-18 08:23:17.111308+00	Working	198451	1	20	t	f	f	2
\.


--
-- Data for Name: companies_department; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_department (id, created_at, updated_at, name, is_hr, timezone, start_inaccuracy, company_id, head_of_department_id) FROM stdin;
2	2024-03-18 08:23:17.112363+00	2024-03-18 08:23:17.112376+00	HR	t	Asia/Almaty	0	2	\N
3	2024-03-19 06:31:45.929121+00	2024-03-19 06:31:45.935618+00	Marketing	f	+05:00	5	2	\N
4	2024-03-19 06:32:01.763246+00	2024-03-19 06:32:01.771062+00	IT	f	+05:00	15	2	\N
\.


--
-- Data for Name: companies_department_zones; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_department_zones (id, department_id, zone_id) FROM stdin;
1	3	1
2	4	1
\.


--
-- Data for Name: companies_role; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_role (id, created_at, updated_at, role, title, grade, checkout_any_time, in_zone, checkout_time, company_id, department_id, user_id) FROM stdin;
1	2024-03-19 04:01:51.719286+00	2024-03-19 04:01:51.719303+00	1	Android dev	1	t	t	0	2	2	3
2	2024-03-19 06:34:07.767276+00	2024-03-19 06:34:07.767294+00	3	Back	3	f	t	15	2	4	4
3	2024-03-19 06:34:59.40966+00	2024-03-19 06:34:59.409681+00	3	Lunovech	2	t	t	5	2	4	5
4	2024-03-19 06:35:36.297228+00	2024-03-19 06:35:36.297247+00	3	Utility	4	t	t	5	2	4	6
5	2024-03-19 06:36:32.647305+00	2024-03-19 06:36:32.647326+00	3	Navigator	4	t	t	5	2	4	7
6	2024-03-19 06:44:08.429872+00	2024-03-19 06:44:08.429889+00	3	Dividych	1	t	t	5	2	3	8
\.


--
-- Data for Name: companies_zone; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_zone (id, created_at, updated_at, address, latitude, longitude, radius, company_id) FROM stdin;
1	2024-03-19 05:18:02.348017+00	2024-03-19 05:18:02.348054+00	Office	43.211114	76.847980	30	2
\.


--
-- Data for Name: companies_zone_employees; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.companies_zone_employees (id, zone_id, role_id) FROM stdin;
1	1	2
2	1	3
3	1	4
4	1	5
5	1	6
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
1	2024-03-19 05:04:02.688569+00	2	EmployeeSchedule object (2)	1	[{"added": {}}]	28	1
2	2024-03-19 05:04:36.214541+00	1	beka@mail.ru - HR @Working @2024-03-19	3		27	1
3	2024-03-19 05:05:00.268069+00	2	EmployeeSchedule object (2)	2	[{"changed": {"fields": ["Week day"]}}]	28	1
4	2024-03-19 05:05:06.714735+00	2	beka@mail.ru - HR @Working @2024-03-19	3		27	1
5	2024-03-19 05:18:29.608466+00	3	beka@mail.ru - HR @Working @2024-03-19	3		27	1
\.


--
-- Data for Name: django_celery_beat_clockedschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_clockedschedule (id, clocked_time) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_crontabschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_crontabschedule (id, minute, hour, day_of_week, day_of_month, month_of_year, timezone) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_intervalschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_intervalschedule (id, every, period) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictask; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_periodictask (id, name, task, args, kwargs, queue, exchange, routing_key, expires, enabled, last_run_at, total_run_count, date_changed, description, crontab_id, interval_id, solar_id, one_off, start_time, priority, headers, clocked_id, expire_seconds) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictasks; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_periodictasks (ident, last_update) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_solarschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_beat_solarschedule (id, event, latitude, longitude) FROM stdin;
\.


--
-- Data for Name: django_celery_results_chordcounter; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_results_chordcounter (id, group_id, sub_tasks, count) FROM stdin;
\.


--
-- Data for Name: django_celery_results_groupresult; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_results_groupresult (id, group_id, date_created, date_done, content_type, content_encoding, result) FROM stdin;
\.


--
-- Data for Name: django_celery_results_taskresult; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_celery_results_taskresult (id, task_id, status, content_type, content_encoding, result, date_done, traceback, meta, task_args, task_kwargs, task_name, worker, date_created, periodic_task_name) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	contenttypes	contenttype
5	sessions	session
6	fcm_django	fcmdevice
7	django_db_logger	statuslog
8	django_celery_beat	crontabschedule
9	django_celery_beat	intervalschedule
10	django_celery_beat	periodictask
11	django_celery_beat	periodictasks
12	django_celery_beat	solarschedule
13	django_celery_beat	clockedschedule
14	django_celery_results	taskresult
15	django_celery_results	chordcounter
16	django_celery_results	groupresult
17	token_blacklist	blacklistedtoken
18	token_blacklist	outstandingtoken
19	auth_user	user
20	auth_user	otptoken
21	auth_user	pendinguser
22	auth_user	resetpasswordtoken
23	companies	company
24	companies	department
25	companies	role
26	companies	zone
27	timesheet	timesheet
28	timesheet	employeeschedule
29	timesheet	departmentschedule
30	scores	score
31	scores	reason
32	checklist	checklist
33	checklist	file
34	checklist	task
35	checklist	taskgroup
36	checklist	taskfile
37	checklist	taskcheck
38	checklist	checklistcomplete
39	checklist	checklistschedule
40	checklist	checklistassign
\.


--
-- Data for Name: django_db_logger_statuslog; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_db_logger_statuslog (id, logger_name, level, msg, trace, create_datetime) FROM stdin;
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2024-03-17 15:53:50.427601+00
2	auth_user	0001_initial	2024-03-17 15:53:50.474775+00
3	admin	0001_initial	2024-03-17 15:53:50.497871+00
4	admin	0002_logentry_remove_auto_add	2024-03-17 15:53:50.503709+00
5	admin	0003_logentry_add_action_flag_choices	2024-03-17 15:53:50.508939+00
6	contenttypes	0002_remove_content_type_name	2024-03-17 15:53:50.52189+00
7	auth	0001_initial	2024-03-17 15:53:50.580166+00
8	auth	0002_alter_permission_name_max_length	2024-03-17 15:53:50.588059+00
9	auth	0003_alter_user_email_max_length	2024-03-17 15:53:50.59349+00
10	auth	0004_alter_user_username_opts	2024-03-17 15:53:50.598877+00
11	auth	0005_alter_user_last_login_null	2024-03-17 15:53:50.60403+00
12	auth	0006_require_contenttypes_0002	2024-03-17 15:53:50.606185+00
13	auth	0007_alter_validators_add_error_messages	2024-03-17 15:53:50.613139+00
14	auth	0008_alter_user_username_max_length	2024-03-17 15:53:50.696853+00
15	auth	0009_alter_user_last_name_max_length	2024-03-17 15:53:50.708445+00
16	auth	0010_alter_group_name_max_length	2024-03-17 15:53:50.719641+00
17	auth	0011_update_proxy_permissions	2024-03-17 15:53:50.728083+00
18	auth	0012_alter_user_first_name_max_length	2024-03-17 15:53:50.7332+00
19	companies	0001_initial	2024-03-17 15:53:50.882372+00
20	auth_user	0002_initial	2024-03-17 15:53:51.021734+00
21	checklist	0001_initial	2024-03-17 15:53:51.281703+00
22	django_celery_beat	0001_initial	2024-03-17 15:53:51.318537+00
23	django_celery_beat	0002_auto_20161118_0346	2024-03-17 15:53:51.333091+00
24	django_celery_beat	0003_auto_20161209_0049	2024-03-17 15:53:51.344754+00
25	django_celery_beat	0004_auto_20170221_0000	2024-03-17 15:53:51.35658+00
26	django_celery_beat	0005_add_solarschedule_events_choices	2024-03-17 15:53:51.363192+00
27	django_celery_beat	0006_auto_20180322_0932	2024-03-17 15:53:51.39076+00
28	django_celery_beat	0007_auto_20180521_0826	2024-03-17 15:53:51.404271+00
29	django_celery_beat	0008_auto_20180914_1922	2024-03-17 15:53:51.421193+00
30	django_celery_beat	0006_auto_20180210_1226	2024-03-17 15:53:51.432427+00
31	django_celery_beat	0006_periodictask_priority	2024-03-17 15:53:51.438917+00
32	django_celery_beat	0009_periodictask_headers	2024-03-17 15:53:51.446841+00
33	django_celery_beat	0010_auto_20190429_0326	2024-03-17 15:53:51.666644+00
34	django_celery_beat	0011_auto_20190508_0153	2024-03-17 15:53:51.684451+00
35	django_celery_beat	0012_periodictask_expire_seconds	2024-03-17 15:53:51.693452+00
36	django_celery_beat	0013_auto_20200609_0727	2024-03-17 15:53:51.699393+00
37	django_celery_beat	0014_remove_clockedschedule_enabled	2024-03-17 15:53:51.704434+00
38	django_celery_beat	0015_edit_solarschedule_events_choices	2024-03-17 15:53:51.715333+00
39	django_celery_beat	0016_alter_crontabschedule_timezone	2024-03-17 15:53:51.724598+00
40	django_celery_beat	0017_alter_crontabschedule_month_of_year	2024-03-17 15:53:51.730111+00
41	django_celery_beat	0018_improve_crontab_helptext	2024-03-17 15:53:51.735715+00
42	django_celery_results	0001_initial	2024-03-17 15:53:51.753909+00
43	django_celery_results	0002_add_task_name_args_kwargs	2024-03-17 15:53:51.762659+00
44	django_celery_results	0003_auto_20181106_1101	2024-03-17 15:53:51.766525+00
45	django_celery_results	0004_auto_20190516_0412	2024-03-17 15:53:51.801998+00
46	django_celery_results	0005_taskresult_worker	2024-03-17 15:53:51.812575+00
47	django_celery_results	0006_taskresult_date_created	2024-03-17 15:53:51.844496+00
48	django_celery_results	0007_remove_taskresult_hidden	2024-03-17 15:53:51.849575+00
49	django_celery_results	0008_chordcounter	2024-03-17 15:53:51.865843+00
50	django_celery_results	0009_groupresult	2024-03-17 15:53:51.954428+00
51	django_celery_results	0010_remove_duplicate_indices	2024-03-17 15:53:51.962468+00
52	django_celery_results	0011_taskresult_periodic_task_name	2024-03-17 15:53:51.967088+00
53	django_db_logger	0001_initial	2024-03-17 15:53:51.979251+00
54	django_db_logger	0002_auto_20190109_0052	2024-03-17 15:53:51.98453+00
55	fcm_django	0001_initial	2024-03-17 15:53:52.016252+00
56	fcm_django	0002_auto_20160808_1645	2024-03-17 15:53:52.042161+00
57	fcm_django	0003_auto_20170313_1314	2024-03-17 15:53:52.056604+00
58	fcm_django	0004_auto_20181128_1642	2024-03-17 15:53:52.069165+00
59	fcm_django	0005_auto_20170808_1145	2024-03-17 15:53:52.08878+00
60	fcm_django	0006_auto_20210802_1140	2024-03-17 15:53:52.101872+00
61	fcm_django	0007_auto_20211001_1440	2024-03-17 15:53:52.128113+00
62	fcm_django	0008_auto_20211224_1205	2024-03-17 15:53:52.155025+00
63	fcm_django	0009_alter_fcmdevice_user	2024-03-17 15:53:52.174003+00
64	fcm_django	0010_unique_registration_id	2024-03-17 15:53:52.192855+00
65	fcm_django	0011_fcmdevice_fcm_django_registration_id_user_id_idx	2024-03-17 15:53:52.210067+00
66	scores	0001_initial	2024-03-17 15:53:52.271691+00
67	sessions	0001_initial	2024-03-17 15:53:52.293934+00
68	timesheet	0001_initial	2024-03-17 15:53:52.513613+00
69	token_blacklist	0001_initial	2024-03-17 15:53:52.582824+00
70	token_blacklist	0002_outstandingtoken_jti_hex	2024-03-17 15:53:52.597765+00
71	token_blacklist	0003_auto_20171017_2007	2024-03-17 15:53:52.628391+00
72	token_blacklist	0004_auto_20171017_2013	2024-03-17 15:53:52.648506+00
73	token_blacklist	0005_remove_outstandingtoken_jti	2024-03-17 15:53:52.664881+00
74	token_blacklist	0006_auto_20171017_2113	2024-03-17 15:53:52.680319+00
75	token_blacklist	0007_auto_20171017_2214	2024-03-17 15:53:52.72295+00
76	token_blacklist	0008_migrate_to_bigautofield	2024-03-17 15:53:52.783848+00
77	token_blacklist	0010_fix_migrate_to_bigautofield	2024-03-17 15:53:52.814163+00
78	token_blacklist	0011_linearizes_history	2024-03-17 15:53:52.81675+00
79	token_blacklist	0012_alter_outstandingtoken_user	2024-03-17 15:53:52.841294+00
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
9plvo02i8f2okesx9vwvbzf88xwtfb94	.eJxVjDsOwyAQBe9CHSED5rMp0_sMaGEhOIlAMnYV5e4RkoukfTPz3szjsRd_9LT5ldiVCXb53QLGZ6oD0APrvfHY6r6tgQ-Fn7TzpVF63U7376BgL6N2qGI2mCxCIgnaOhLOapMVJDWhNDI40kbNVlCE2WoIbqKA2RBgFuzzBe5dOCI:1rm8CN:MvF5CWMRrVwRoQr7SZKSXccdAyP1WNv32pbvzFzSw-o	2024-04-01 08:18:23.323845+00
xog60ws07vy3keghhyh78nu9ib2zdm8m	.eJxVjDsOwyAQBe9CHSED5rMp0_sMaGEhOIlAMnYV5e4RkoukfTPz3szjsRd_9LT5ldiVCXb53QLGZ6oD0APrvfHY6r6tgQ-Fn7TzpVF63U7376BgL6N2qGI2mCxCIgnaOhLOapMVJDWhNDI40kbNVlCE2WoIbqKA2RBgFuzzBe5dOCI:1rm8z9:oL8vKUftXOIvktE7xSnX4PL-3uReKD59HRNne20TTXA	2024-04-01 09:08:47.307704+00
014s2mhg82rnsvmkj8hdtyhbjz9hblek	.eJxVjDsOwyAQBe9CHSED5rMp0_sMaGEhOIlAMnYV5e4RkoukfTPz3szjsRd_9LT5ldiVCXb53QLGZ6oD0APrvfHY6r6tgQ-Fn7TzpVF63U7376BgL6N2qGI2mCxCIgnaOhLOapMVJDWhNDI40kbNVlCE2WoIbqKA2RBgFuzzBe5dOCI:1rmRdE:1kLamojpkOxZH5eo_FQ-nGkv3hGCxlGLZXZ22YdE1kY	2024-04-02 05:03:24.702317+00
\.


--
-- Data for Name: fcm_django_fcmdevice; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.fcm_django_fcmdevice (id, name, active, date_created, device_id, registration_id, type, user_id) FROM stdin;
\.


--
-- Data for Name: scores_reason; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.scores_reason (id, created_at, updated_at, name, type, score, company_id) FROM stdin;
10	2024-03-18 08:23:17.114831+00	2024-03-18 08:23:17.114841+00		2	-10	2
11	2024-03-18 08:23:17.114876+00	2024-03-18 08:23:17.114879+00		3	-10	2
12	2024-03-18 08:23:17.11489+00	2024-03-18 08:23:17.114893+00		10	-15	2
13	2024-03-18 08:23:17.114902+00	2024-03-18 08:23:17.11491+00		4	-2	2
14	2024-03-18 08:23:17.114919+00	2024-03-18 08:23:17.114922+00		5	-5	2
15	2024-03-18 08:23:17.114931+00	2024-03-18 08:23:17.114934+00		6	-10	2
16	2024-03-18 08:23:17.114943+00	2024-03-18 08:23:17.114947+00		7	1	2
17	2024-03-18 08:23:17.114956+00	2024-03-18 08:23:17.114959+00		8	3	2
18	2024-03-18 08:23:17.114969+00	2024-03-18 08:23:17.114972+00		9	5	2
\.


--
-- Data for Name: scores_score; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.scores_score (id, created_at, updated_at, reason_type, name, points, created_by_id, role_id) FROM stdin;
1	2024-03-19 05:12:33.638626+00	2024-03-19 05:12:33.638645+00	2		-10	\N	1
\.


--
-- Data for Name: timesheet_departmentschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.timesheet_departmentschedule (id, created_at, updated_at, week_day, time_from, time_to, department_id) FROM stdin;
6	2024-03-18 08:23:17.113465+00	2024-03-18 08:23:17.113476+00	0	09:00:00	18:00:00	2
7	2024-03-18 08:23:17.113522+00	2024-03-18 08:23:17.113526+00	1	09:00:00	18:00:00	2
8	2024-03-18 08:23:17.113541+00	2024-03-18 08:23:17.113544+00	2	09:00:00	18:00:00	2
9	2024-03-18 08:23:17.113557+00	2024-03-18 08:23:17.11356+00	3	09:00:00	18:00:00	2
10	2024-03-18 08:23:17.113572+00	2024-03-18 08:23:17.113575+00	4	09:00:00	18:00:00	2
11	2024-03-19 06:31:45.932055+00	2024-03-19 06:31:45.932074+00	2	09:00:00	18:00:00	3
12	2024-03-19 06:32:01.767104+00	2024-03-19 06:32:01.767127+00	2	11:00:00	15:00:00	4
\.


--
-- Data for Name: timesheet_employeeschedule; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.timesheet_employeeschedule (id, created_at, updated_at, time_from, time_to, is_night_shift, is_remote, week_day, role_id) FROM stdin;
1	2024-03-19 04:01:51.72576+00	2024-03-19 04:01:51.72578+00	09:00:00	18:00:00	f	f	5	1
2	2024-03-19 05:04:02.687265+00	2024-03-19 05:05:00.266646+00	09:00:00	18:00:00	f	f	1	1
3	2024-03-19 06:34:07.77188+00	2024-03-19 06:34:07.771898+00	10:00:00	12:00:00	f	f	2	2
4	2024-03-19 06:34:59.413594+00	2024-03-19 06:34:59.413612+00	10:00:00	12:00:00	f	f	2	3
5	2024-03-19 06:35:36.300405+00	2024-03-19 06:35:36.300419+00	11:00:00	15:00:00	f	f	2	4
6	2024-03-19 06:36:32.651587+00	2024-03-19 06:36:32.651605+00	11:00:00	15:00:00	f	f	2	5
7	2024-03-19 06:44:08.433649+00	2024-03-19 06:44:08.433666+00	11:00:00	15:00:00	f	f	2	6
\.


--
-- Data for Name: timesheet_timesheet; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.timesheet_timesheet (id, created_at, updated_at, day, device_id, check_in, check_out, time_from, time_to, comment, debug_comment, file, status, timezone, is_night_shift, is_remote, role_id) FROM stdin;
4	2024-03-19 06:05:43.356762+00	2024-03-19 06:05:43.356785+00	2024-03-19		\N	\N	09:00:00	18:00:00				6	+05:00	f	f	1
\.


--
-- Data for Name: token_blacklist_blacklistedtoken; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.token_blacklist_blacklistedtoken (id, blacklisted_at, token_id) FROM stdin;
\.


--
-- Data for Name: token_blacklist_outstandingtoken; Type: TABLE DATA; Schema: public; Owner: damir
--

COPY public.token_blacklist_outstandingtoken (id, token, created_at, expires_at, user_id, jti) FROM stdin;
1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwMzU4MSwiaWF0IjoxNzEwODE3MTgxLCJqdGkiOiJmYjAyNjg4NjZiMzc0Mzg3ODI0Yzk1Y2RmN2FiNWU5ZiIsInVzZXJfaWQiOjJ9.RACm8Zellwx2sLGvNFloUHqG_oCTFeoCYEaQf2HbNgY	2024-03-19 02:59:41.285986+00	2024-03-20 02:59:41+00	2	fb0268866b374387824c95cdf7ab5e9f
2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwNjAwOSwiaWF0IjoxNzEwODE5NjA5LCJqdGkiOiI3ZTcxNWZmZGQ0OGE0ODgyYTQ2ZDY4YzA1NmJkYzk3OSIsInVzZXJfaWQiOjJ9.89z4-wR0hYy-wjUh-IFiFuztnEW9NUrkNSvrTL8M7Zo	2024-03-19 03:40:09.139764+00	2024-03-20 03:40:09+00	2	7e715ffdd48a4882a46d68c056bdc979
3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwNjM0MiwiaWF0IjoxNzEwODE5OTQyLCJqdGkiOiI4YTI3ODAxMDQwNjY0MzZlOWYwNmNlODQ3YmU0MWNlOCIsInVzZXJfaWQiOjJ9.-oGCctFgFu4gHsrRYcBoiZxWkTrrfs9yOcNMnjMvO_E	2024-03-19 03:45:42.430663+00	2024-03-20 03:45:42+00	2	8a2780104066436e9f06ce847be41ce8
4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwNzMzNywiaWF0IjoxNzEwODIwOTM3LCJqdGkiOiI2OGFmZmE5YTRjNzQ0OTc3YTVkMDBjYjlhNGYyN2QzMiIsInVzZXJfaWQiOjN9.Pn87CX11QxwweXgokiCunllVfDkTspiB2G9O5grD9UA	2024-03-19 04:02:17.26782+00	2024-03-20 04:02:17+00	3	68affa9a4c744977a5d00cb9a4f27d32
5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwNzY4MiwiaWF0IjoxNzEwODIxMjgyLCJqdGkiOiIzMTc5ZGQwMTIwYWY0MWQ3ODE5YzE5OTIxMjJlZDkwMSIsInVzZXJfaWQiOjN9.kv84iSjH6Qgt5Vixk4Iqzt0Z3BRDKl7EdM14eDgMfHU	2024-03-19 04:08:02.479787+00	2024-03-20 04:08:02+00	3	3179dd0120af41d7819c1992122ed901
6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkwNzY5NSwiaWF0IjoxNzEwODIxMjk1LCJqdGkiOiJiMTI3ZTY5NmFkOTU0MjNjOGQxZjczZjJkNGZjZGE4NSIsInVzZXJfaWQiOjN9.ZQklgYGJbmYLK24c2_bUMQxU9Z0U59r0yRoafo9Xua0	2024-03-19 04:08:15.148133+00	2024-03-20 04:08:15+00	3	b127e696ad95423c8d1f73f2d4fcda85
7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxMDIxMiwiaWF0IjoxNzEwODIzODEyLCJqdGkiOiI5OGYxODk3YzJjZTE0YjhmOGU1NjNhMzAyOGQwNjIxZSIsInVzZXJfaWQiOjN9.JAJ1oUOeNAmg0_EqnGoZXzGTVyQsH9Etu4o3WqDrP9w	2024-03-19 04:50:12.262593+00	2024-03-20 04:50:12+00	3	98f1897c2ce14b8f8e563a3028d0621e
8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxMDM0MywiaWF0IjoxNzEwODIzOTQzLCJqdGkiOiIxNDFkN2NlOGZlYTQ0OWViYmE4NWZjYTgwODMzZGUyZSIsInVzZXJfaWQiOjN9.ZHO-EaG_Igd0BQw2UXUrqZLlkMRJ8W7yEiL6d_g48uI	2024-03-19 04:52:23.729453+00	2024-03-20 04:52:23+00	3	141d7ce8fea449ebba85fca80833de2e
9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxMDUyOSwiaWF0IjoxNzEwODI0MTI5LCJqdGkiOiIxOWUyNmFmYTA2NjU0ZDViODAwZDQxNjRjYmVlODYwMyIsInVzZXJfaWQiOjN9.zVoxl5ONwB3Hy1nWNSesQlEAwKS8mAH5bd2NOIEMHBE	2024-03-19 04:55:29.67728+00	2024-03-20 04:55:29+00	3	19e26afa06654d5b800d4164cbee8603
10	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxMTA1OSwiaWF0IjoxNzEwODI0NjU5LCJqdGkiOiI2ZTk1YjZiZjAwNWM0YmE1ODNiZjY4YTRlYTE5MzYwNiIsInVzZXJfaWQiOjN9.OtHbq5rnUve-2SAuATyWP2zy8DGYL7ZUIwSInWFvzKc	2024-03-19 05:04:19.132068+00	2024-03-20 05:04:19+00	3	6e95b6bf005c4ba583bf68a4ea193606
11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxNDE2MCwiaWF0IjoxNzEwODI3NzYwLCJqdGkiOiI5ZjgxNWE0YjlmODA0NjQ5YTVlMTZkM2VjN2IxYTY0NiIsInVzZXJfaWQiOjN9.GX32uXruooYsTbKdkii_K-khUMPa3A5pslJYAcKqmTE	2024-03-19 05:56:00.989923+00	2024-03-20 05:56:00+00	3	9f815a4b9f804649a5e16d3ec7b1a646
12	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxNDc0MiwiaWF0IjoxNzEwODI4MzQyLCJqdGkiOiJmZjMxMTc3ZjM3MDM0NmFhODhmMTNkNmIwMzk1MTMzMyIsInVzZXJfaWQiOjN9.C6DA5M6t6D5FkChh0mSF1fRJ1vhfUxbxLydSZo5MMpw	2024-03-19 06:05:42.458813+00	2024-03-20 06:05:42+00	3	ff31177f370346aa88f13d6b03951333
13	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxNjYxMSwiaWF0IjoxNzEwODMwMjExLCJqdGkiOiJkYWJkYzQ0YTFiYzU0MzM4YmM2Y2NjMTI2NDY5Yjc0ZSIsInVzZXJfaWQiOjN9.P__GwrZe32VvZ-cWQdGabNDdwweUhNUPInvIYd6VP8Y	2024-03-19 06:36:51.231789+00	2024-03-20 06:36:51+00	3	dabdc44a1bc54338bc6ccc126469b74e
14	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxNjk3NSwiaWF0IjoxNzEwODMwNTc1LCJqdGkiOiI4OGE1M2Y2YjExNGI0MGU3YjAwNjI5MzNlMWRkZGY4YSIsInVzZXJfaWQiOjN9.hFLwYyNm8wDtyirXU90-6tVrLFLytz_ZfaAV3yRq7QA	2024-03-19 06:42:55.382627+00	2024-03-20 06:42:55+00	3	88a53f6b114b40e7b0062933e1dddf8a
15	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkxNzEwNywiaWF0IjoxNzEwODMwNzA3LCJqdGkiOiJiMDJjMGI5MmZjYzk0YTY4ODI1OWM3YzU2OTU0ZTE3YyIsInVzZXJfaWQiOjN9.tBWkIkdPFgIYSOWD8tIV3YqS2SUaxN5bEDQ0k0RTaPY	2024-03-19 06:45:07.726404+00	2024-03-20 06:45:07+00	3	b02c0b92fcc94a688259c7c56954e17c
16	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkyMjU2NSwiaWF0IjoxNzEwODM2MTY1LCJqdGkiOiI0MDMxOTM0ODk0ZmQ0MDAyOTg4MzdkZTM1MDExZGIxOCIsInVzZXJfaWQiOjN9.qBbYjh_BVqABFDFsUNwsZ3cCEWK1se9PhT9skQbAWdA	2024-03-19 08:16:05.859556+00	2024-03-20 08:16:05+00	3	4031934894fd400298837de35011db18
17	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkyNDA4NywiaWF0IjoxNzEwODM3Njg3LCJqdGkiOiI1ZGQyNmM2MTMzODA0OWZjOGYzNzBiN2RmMGU1ZDg2ZiIsInVzZXJfaWQiOjN9.hzpAtn9DWXjAF5LDMT_Y9LTRJaNVrd37eMMB_PelYTc	2024-03-19 08:41:27.800984+00	2024-03-20 08:41:27+00	3	5dd26c61338049fc8f370b7df0e5d86f
18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkyNDQ0MywiaWF0IjoxNzEwODM4MDQzLCJqdGkiOiJkZTNjZGRmYzhiYWM0MDIyOThhNzg5YjJlOTU1NzljYSIsInVzZXJfaWQiOjN9.SDouRortY4SFOGGWz2T3CJSEVWsdn4Joh9lOrTPgGNE	2024-03-19 08:47:23.307186+00	2024-03-20 08:47:23+00	3	de3cddfc8bac402298a789b2e95579ca
19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkyNDQ5OCwiaWF0IjoxNzEwODM4MDk4LCJqdGkiOiI4ZTYwNDgzODYyM2Y0NzZhYWE2MTI4Y2JlYzA5YzgwMCIsInVzZXJfaWQiOjN9.VKnMlTyWwqwMJqOIS6IDD6i1HQh02-JTtXvy6k8vaL8	2024-03-19 08:48:18.314997+00	2024-03-20 08:48:18+00	3	8e604838623f476aaa6128cbec09c800
20	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTcxMDkyNDUzOCwiaWF0IjoxNzEwODM4MTM4LCJqdGkiOiJlMWQzNTZhNTUzZGI0OWFhYjRjZTY0MTkxNDFhMjlmNSIsInVzZXJfaWQiOjN9.ZstKN9nnnzD_JeD24vP6zeHNaD6IXMKXhkOl42TUFNI	2024-03-19 08:48:58.189439+00	2024-03-20 08:48:58+00	3	e1d356a553db49aab4ce6419141a29f5
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 160, true);


--
-- Name: auth_user_otptoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_otptoken_id_seq', 10, true);


--
-- Name: auth_user_pendinguser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_pendinguser_id_seq', 3, true);


--
-- Name: auth_user_resetpasswordtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_resetpasswordtoken_id_seq', 1, true);


--
-- Name: auth_user_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_user_groups_id_seq', 1, false);


--
-- Name: auth_user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_user_id_seq', 8, true);


--
-- Name: auth_user_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.auth_user_user_user_permissions_id_seq', 1, false);


--
-- Name: checklist_checklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_checklist_id_seq', 1, false);


--
-- Name: checklist_checklistassign_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_checklistassign_id_seq', 1, false);


--
-- Name: checklist_checklistcomplete_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_checklistcomplete_id_seq', 1, false);


--
-- Name: checklist_checklistschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_checklistschedule_id_seq', 1, false);


--
-- Name: checklist_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_file_id_seq', 1, false);


--
-- Name: checklist_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_task_id_seq', 1, false);


--
-- Name: checklist_taskcheck_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_taskcheck_id_seq', 1, false);


--
-- Name: checklist_taskfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_taskfile_id_seq', 1, false);


--
-- Name: checklist_taskgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.checklist_taskgroup_id_seq', 1, false);


--
-- Name: companies_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_company_id_seq', 2, true);


--
-- Name: companies_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_department_id_seq', 4, true);


--
-- Name: companies_department_zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_department_zones_id_seq', 2, true);


--
-- Name: companies_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_role_id_seq', 6, true);


--
-- Name: companies_zone_employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_zone_employees_id_seq', 5, true);


--
-- Name: companies_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.companies_zone_id_seq', 1, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 5, true);


--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_beat_clockedschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_beat_crontabschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_beat_intervalschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_beat_periodictask_id_seq', 1, false);


--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_beat_solarschedule_id_seq', 1, false);


--
-- Name: django_celery_results_chordcounter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_results_chordcounter_id_seq', 1, false);


--
-- Name: django_celery_results_groupresult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_results_groupresult_id_seq', 1, false);


--
-- Name: django_celery_results_taskresult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_celery_results_taskresult_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 40, true);


--
-- Name: django_db_logger_statuslog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_db_logger_statuslog_id_seq', 1, false);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 79, true);


--
-- Name: fcm_django_fcmdevice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.fcm_django_fcmdevice_id_seq', 1, false);


--
-- Name: scores_reason_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.scores_reason_id_seq', 18, true);


--
-- Name: scores_score_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.scores_score_id_seq', 1, true);


--
-- Name: timesheet_departmentschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.timesheet_departmentschedule_id_seq', 12, true);


--
-- Name: timesheet_employeeschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.timesheet_employeeschedule_id_seq', 7, true);


--
-- Name: timesheet_timesheet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.timesheet_timesheet_id_seq', 4, true);


--
-- Name: token_blacklist_blacklistedtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.token_blacklist_blacklistedtoken_id_seq', 1, false);


--
-- Name: token_blacklist_outstandingtoken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: damir
--

SELECT pg_catalog.setval('public.token_blacklist_outstandingtoken_id_seq', 20, true);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_otptoken auth_user_otptoken_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_otptoken
    ADD CONSTRAINT auth_user_otptoken_pkey PRIMARY KEY (id);


--
-- Name: auth_user_pendinguser auth_user_pendinguser_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_pendinguser
    ADD CONSTRAINT auth_user_pendinguser_pkey PRIMARY KEY (id);


--
-- Name: auth_user_resetpasswordtoken auth_user_resetpasswordtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_resetpasswordtoken
    ADD CONSTRAINT auth_user_resetpasswordtoken_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user auth_user_user_email_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user
    ADD CONSTRAINT auth_user_user_email_key UNIQUE (email);


--
-- Name: auth_user_user_groups auth_user_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_groups
    ADD CONSTRAINT auth_user_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_groups auth_user_user_groups_user_id_group_id_fca56026_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_groups
    ADD CONSTRAINT auth_user_user_groups_user_id_group_id_fca56026_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user_user auth_user_user_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user
    ADD CONSTRAINT auth_user_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_user_permissions auth_user_user_user_perm_user_id_permission_id_14b3010f_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_user_permissions
    ADD CONSTRAINT auth_user_user_user_perm_user_id_permission_id_14b3010f_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user_user_user_permissions auth_user_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_user_permissions
    ADD CONSTRAINT auth_user_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: checklist_checklist checklist_checklist_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklist
    ADD CONSTRAINT checklist_checklist_pkey PRIMARY KEY (id);


--
-- Name: checklist_checklistassign checklist_checklistassig_user_id_checklist_id_typ_f6cbf41a_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistassign
    ADD CONSTRAINT checklist_checklistassig_user_id_checklist_id_typ_f6cbf41a_uniq UNIQUE (user_id, checklist_id, type);


--
-- Name: checklist_checklistassign checklist_checklistassign_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistassign
    ADD CONSTRAINT checklist_checklistassign_pkey PRIMARY KEY (id);


--
-- Name: checklist_checklistcomplete checklist_checklistcomplete_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistcomplete
    ADD CONSTRAINT checklist_checklistcomplete_pkey PRIMARY KEY (id);


--
-- Name: checklist_checklistschedule checklist_checklistschedule_checklist_id_week_day_85ddca9a_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistschedule
    ADD CONSTRAINT checklist_checklistschedule_checklist_id_week_day_85ddca9a_uniq UNIQUE (checklist_id, week_day);


--
-- Name: checklist_checklistschedule checklist_checklistschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistschedule
    ADD CONSTRAINT checklist_checklistschedule_pkey PRIMARY KEY (id);


--
-- Name: checklist_file checklist_file_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_file
    ADD CONSTRAINT checklist_file_pkey PRIMARY KEY (id);


--
-- Name: checklist_task checklist_task_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_task
    ADD CONSTRAINT checklist_task_pkey PRIMARY KEY (id);


--
-- Name: checklist_taskcheck checklist_taskcheck_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskcheck
    ADD CONSTRAINT checklist_taskcheck_pkey PRIMARY KEY (id);


--
-- Name: checklist_taskfile checklist_taskfile_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskfile
    ADD CONSTRAINT checklist_taskfile_pkey PRIMARY KEY (id);


--
-- Name: checklist_taskgroup checklist_taskgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskgroup
    ADD CONSTRAINT checklist_taskgroup_pkey PRIMARY KEY (id);


--
-- Name: companies_company companies_company_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_company
    ADD CONSTRAINT companies_company_invite_code_key UNIQUE (invite_code);


--
-- Name: companies_company companies_company_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_company
    ADD CONSTRAINT companies_company_pkey PRIMARY KEY (id);


--
-- Name: companies_department companies_department_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department
    ADD CONSTRAINT companies_department_pkey PRIMARY KEY (id);


--
-- Name: companies_department_zones companies_department_zones_department_id_zone_id_b64afa66_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department_zones
    ADD CONSTRAINT companies_department_zones_department_id_zone_id_b64afa66_uniq UNIQUE (department_id, zone_id);


--
-- Name: companies_department_zones companies_department_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department_zones
    ADD CONSTRAINT companies_department_zones_pkey PRIMARY KEY (id);


--
-- Name: companies_role companies_role_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role
    ADD CONSTRAINT companies_role_pkey PRIMARY KEY (id);


--
-- Name: companies_role companies_role_user_id_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role
    ADD CONSTRAINT companies_role_user_id_key UNIQUE (user_id);


--
-- Name: companies_zone_employees companies_zone_employees_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone_employees
    ADD CONSTRAINT companies_zone_employees_pkey PRIMARY KEY (id);


--
-- Name: companies_zone_employees companies_zone_employees_zone_id_role_id_3befe63d_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone_employees
    ADD CONSTRAINT companies_zone_employees_zone_id_role_id_3befe63d_uniq UNIQUE (zone_id, role_id);


--
-- Name: companies_zone companies_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone
    ADD CONSTRAINT companies_zone_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_clockedschedule django_celery_beat_clockedschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule
    ADD CONSTRAINT django_celery_beat_clockedschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_crontabschedule django_celery_beat_crontabschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule
    ADD CONSTRAINT django_celery_beat_crontabschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_intervalschedule django_celery_beat_intervalschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule
    ADD CONSTRAINT django_celery_beat_intervalschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_name_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_name_key UNIQUE (name);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictasks django_celery_beat_periodictasks_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictasks
    ADD CONSTRAINT django_celery_beat_periodictasks_pkey PRIMARY KEY (ident);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq UNIQUE (event, latitude, longitude);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solarschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solarschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_results_chordcounter django_celery_results_chordcounter_group_id_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_chordcounter
    ADD CONSTRAINT django_celery_results_chordcounter_group_id_key UNIQUE (group_id);


--
-- Name: django_celery_results_chordcounter django_celery_results_chordcounter_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_chordcounter
    ADD CONSTRAINT django_celery_results_chordcounter_pkey PRIMARY KEY (id);


--
-- Name: django_celery_results_groupresult django_celery_results_groupresult_group_id_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_groupresult
    ADD CONSTRAINT django_celery_results_groupresult_group_id_key UNIQUE (group_id);


--
-- Name: django_celery_results_groupresult django_celery_results_groupresult_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_groupresult
    ADD CONSTRAINT django_celery_results_groupresult_pkey PRIMARY KEY (id);


--
-- Name: django_celery_results_taskresult django_celery_results_taskresult_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_taskresult
    ADD CONSTRAINT django_celery_results_taskresult_pkey PRIMARY KEY (id);


--
-- Name: django_celery_results_taskresult django_celery_results_taskresult_task_id_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_results_taskresult
    ADD CONSTRAINT django_celery_results_taskresult_task_id_key UNIQUE (task_id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_db_logger_statuslog django_db_logger_statuslog_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_db_logger_statuslog
    ADD CONSTRAINT django_db_logger_statuslog_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: fcm_django_fcmdevice fcm_django_fcmdevice_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.fcm_django_fcmdevice
    ADD CONSTRAINT fcm_django_fcmdevice_pkey PRIMARY KEY (id);


--
-- Name: fcm_django_fcmdevice fcm_django_fcmdevice_registration_id_9918b353_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.fcm_django_fcmdevice
    ADD CONSTRAINT fcm_django_fcmdevice_registration_id_9918b353_uniq UNIQUE (registration_id);


--
-- Name: scores_reason scores_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_reason
    ADD CONSTRAINT scores_reason_pkey PRIMARY KEY (id);


--
-- Name: scores_score scores_score_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_score
    ADD CONSTRAINT scores_score_pkey PRIMARY KEY (id);


--
-- Name: timesheet_departmentschedule timesheet_departmentsche_department_id_week_day_af4652af_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_departmentschedule
    ADD CONSTRAINT timesheet_departmentsche_department_id_week_day_af4652af_uniq UNIQUE (department_id, week_day);


--
-- Name: timesheet_departmentschedule timesheet_departmentschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_departmentschedule
    ADD CONSTRAINT timesheet_departmentschedule_pkey PRIMARY KEY (id);


--
-- Name: timesheet_employeeschedule timesheet_employeeschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_employeeschedule
    ADD CONSTRAINT timesheet_employeeschedule_pkey PRIMARY KEY (id);


--
-- Name: timesheet_timesheet timesheet_timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_timesheet
    ADD CONSTRAINT timesheet_timesheet_pkey PRIMARY KEY (id);


--
-- Name: token_blacklist_blacklistedtoken token_blacklist_blacklistedtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_blacklistedtoken
    ADD CONSTRAINT token_blacklist_blacklistedtoken_pkey PRIMARY KEY (id);


--
-- Name: token_blacklist_blacklistedtoken token_blacklist_blacklistedtoken_token_id_key; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_blacklistedtoken
    ADD CONSTRAINT token_blacklist_blacklistedtoken_token_id_key UNIQUE (token_id);


--
-- Name: token_blacklist_outstandingtoken token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_uniq; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_outstandingtoken
    ADD CONSTRAINT token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_uniq UNIQUE (jti);


--
-- Name: token_blacklist_outstandingtoken token_blacklist_outstandingtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_outstandingtoken
    ADD CONSTRAINT token_blacklist_outstandingtoken_pkey PRIMARY KEY (id);


--
-- Name: companies_department unique name-company; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department
    ADD CONSTRAINT "unique name-company" UNIQUE (name, company_id);


--
-- Name: timesheet_employeeschedule unique schedule; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_employeeschedule
    ADD CONSTRAINT "unique schedule" UNIQUE (role_id, week_day);


--
-- Name: timesheet_timesheet unique timesheet; Type: CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_timesheet
    ADD CONSTRAINT "unique timesheet" UNIQUE (role_id, day);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_otptoken_company_id_9f5a9c29; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_otptoken_company_id_9f5a9c29 ON public.auth_user_otptoken USING btree (company_id);


--
-- Name: auth_user_otptoken_user_id_b0f35f22; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_otptoken_user_id_b0f35f22 ON public.auth_user_otptoken USING btree (user_id);


--
-- Name: auth_user_pendinguser_department_id_c04ea59b; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_pendinguser_department_id_c04ea59b ON public.auth_user_pendinguser USING btree (department_id);


--
-- Name: auth_user_resetpasswordtoken_user_id_51c401c1; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_resetpasswordtoken_user_id_51c401c1 ON public.auth_user_resetpasswordtoken USING btree (user_id);


--
-- Name: auth_user_user_email_86d6e319_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_email_86d6e319_like ON public.auth_user_user USING btree (email varchar_pattern_ops);


--
-- Name: auth_user_user_groups_group_id_f9a20b05; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_groups_group_id_f9a20b05 ON public.auth_user_user_groups USING btree (group_id);


--
-- Name: auth_user_user_groups_user_id_9fd2c989; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_groups_user_id_9fd2c989 ON public.auth_user_user_groups USING btree (user_id);


--
-- Name: auth_user_user_owner_id_eb2cf8ce; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_owner_id_eb2cf8ce ON public.auth_user_user USING btree (owner_id);


--
-- Name: auth_user_user_selected_company_id_10295ecd; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_selected_company_id_10295ecd ON public.auth_user_user USING btree (selected_company_id);


--
-- Name: auth_user_user_user_permissions_permission_id_2900c446; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_user_permissions_permission_id_2900c446 ON public.auth_user_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_user_permissions_user_id_6afc8fee; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX auth_user_user_user_permissions_user_id_6afc8fee ON public.auth_user_user_user_permissions USING btree (user_id);


--
-- Name: checklist_checklist_company_id_f6a65f4a; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklist_company_id_f6a65f4a ON public.checklist_checklist USING btree (company_id);


--
-- Name: checklist_checklist_department_id_d5803019; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklist_department_id_d5803019 ON public.checklist_checklist USING btree (department_id);


--
-- Name: checklist_checklistassign_checklist_id_afd8f4c4; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklistassign_checklist_id_afd8f4c4 ON public.checklist_checklistassign USING btree (checklist_id);


--
-- Name: checklist_checklistassign_user_id_793aa2d8; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklistassign_user_id_793aa2d8 ON public.checklist_checklistassign USING btree (user_id);


--
-- Name: checklist_checklistcomplete_checklist_id_01a4ab98; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklistcomplete_checklist_id_01a4ab98 ON public.checklist_checklistcomplete USING btree (checklist_id);


--
-- Name: checklist_checklistcomplete_user_id_afe4b9fb; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklistcomplete_user_id_afe4b9fb ON public.checklist_checklistcomplete USING btree (user_id);


--
-- Name: checklist_checklistschedule_checklist_id_f00ec341; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_checklistschedule_checklist_id_f00ec341 ON public.checklist_checklistschedule USING btree (checklist_id);


--
-- Name: checklist_file_uploaded_by_id_37f0f59e; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_file_uploaded_by_id_37f0f59e ON public.checklist_file USING btree (uploaded_by_id);


--
-- Name: checklist_task_group_id_f10a2db5; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_task_group_id_f10a2db5 ON public.checklist_task USING btree (group_id);


--
-- Name: checklist_taskcheck_task_id_99307548; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_taskcheck_task_id_99307548 ON public.checklist_taskcheck USING btree (task_id);


--
-- Name: checklist_taskcheck_user_id_9cda16eb; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_taskcheck_user_id_9cda16eb ON public.checklist_taskcheck USING btree (user_id);


--
-- Name: checklist_taskfile_file_id_5f0f1972; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_taskfile_file_id_5f0f1972 ON public.checklist_taskfile USING btree (file_id);


--
-- Name: checklist_taskfile_task_id_809b677b; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_taskfile_task_id_809b677b ON public.checklist_taskfile USING btree (task_id);


--
-- Name: checklist_taskgroup_checklist_id_d7155899; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX checklist_taskgroup_checklist_id_d7155899 ON public.checklist_taskgroup USING btree (checklist_id);


--
-- Name: companies_company_invite_code_c2cf27eb_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_company_invite_code_c2cf27eb_like ON public.companies_company USING btree (invite_code varchar_pattern_ops);


--
-- Name: companies_company_owner_id_89314e2a; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_company_owner_id_89314e2a ON public.companies_company USING btree (owner_id);


--
-- Name: companies_department_company_id_fd75b821; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_department_company_id_fd75b821 ON public.companies_department USING btree (company_id);


--
-- Name: companies_department_head_of_department_id_d3999b0a; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_department_head_of_department_id_d3999b0a ON public.companies_department USING btree (head_of_department_id);


--
-- Name: companies_department_zones_department_id_e966ba85; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_department_zones_department_id_e966ba85 ON public.companies_department_zones USING btree (department_id);


--
-- Name: companies_department_zones_zone_id_d04dea90; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_department_zones_zone_id_d04dea90 ON public.companies_department_zones USING btree (zone_id);


--
-- Name: companies_role_company_id_c4cb615b; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_role_company_id_c4cb615b ON public.companies_role USING btree (company_id);


--
-- Name: companies_role_department_id_4b4f2515; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_role_department_id_4b4f2515 ON public.companies_role USING btree (department_id);


--
-- Name: companies_zone_company_id_c9498d65; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_zone_company_id_c9498d65 ON public.companies_zone USING btree (company_id);


--
-- Name: companies_zone_employees_role_id_5b6d4258; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_zone_employees_role_id_5b6d4258 ON public.companies_zone_employees USING btree (role_id);


--
-- Name: companies_zone_employees_zone_id_7a22a12a; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX companies_zone_employees_zone_id_7a22a12a ON public.companies_zone_employees USING btree (zone_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_cele_date_cr_bd6c1d_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_date_cr_bd6c1d_idx ON public.django_celery_results_groupresult USING btree (date_created);


--
-- Name: django_cele_date_cr_f04a50_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_date_cr_f04a50_idx ON public.django_celery_results_taskresult USING btree (date_created);


--
-- Name: django_cele_date_do_caae0e_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_date_do_caae0e_idx ON public.django_celery_results_groupresult USING btree (date_done);


--
-- Name: django_cele_date_do_f59aad_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_date_do_f59aad_idx ON public.django_celery_results_taskresult USING btree (date_done);


--
-- Name: django_cele_status_9b6201_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_status_9b6201_idx ON public.django_celery_results_taskresult USING btree (status);


--
-- Name: django_cele_task_na_08aec9_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_task_na_08aec9_idx ON public.django_celery_results_taskresult USING btree (task_name);


--
-- Name: django_cele_worker_d54dd8_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_cele_worker_d54dd8_idx ON public.django_celery_results_taskresult USING btree (worker);


--
-- Name: django_celery_beat_periodictask_clocked_id_47a69f82; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_beat_periodictask_clocked_id_47a69f82 ON public.django_celery_beat_periodictask USING btree (clocked_id);


--
-- Name: django_celery_beat_periodictask_crontab_id_d3cba168; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_beat_periodictask_crontab_id_d3cba168 ON public.django_celery_beat_periodictask USING btree (crontab_id);


--
-- Name: django_celery_beat_periodictask_interval_id_a8ca27da; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_beat_periodictask_interval_id_a8ca27da ON public.django_celery_beat_periodictask USING btree (interval_id);


--
-- Name: django_celery_beat_periodictask_name_265a36b7_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_beat_periodictask_name_265a36b7_like ON public.django_celery_beat_periodictask USING btree (name varchar_pattern_ops);


--
-- Name: django_celery_beat_periodictask_solar_id_a87ce72c; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_beat_periodictask_solar_id_a87ce72c ON public.django_celery_beat_periodictask USING btree (solar_id);


--
-- Name: django_celery_results_chordcounter_group_id_1f70858c_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_results_chordcounter_group_id_1f70858c_like ON public.django_celery_results_chordcounter USING btree (group_id varchar_pattern_ops);


--
-- Name: django_celery_results_groupresult_group_id_a085f1a9_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_results_groupresult_group_id_a085f1a9_like ON public.django_celery_results_groupresult USING btree (group_id varchar_pattern_ops);


--
-- Name: django_celery_results_taskresult_task_id_de0d95bf_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_celery_results_taskresult_task_id_de0d95bf_like ON public.django_celery_results_taskresult USING btree (task_id varchar_pattern_ops);


--
-- Name: django_db_logger_statuslog_level_3c380d31; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_db_logger_statuslog_level_3c380d31 ON public.django_db_logger_statuslog USING btree (level);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: fcm_django__registr_dacdb2_idx; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX fcm_django__registr_dacdb2_idx ON public.fcm_django_fcmdevice USING btree (registration_id, user_id);


--
-- Name: fcm_django_fcmdevice_device_id_a9406c36; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX fcm_django_fcmdevice_device_id_a9406c36 ON public.fcm_django_fcmdevice USING btree (device_id);


--
-- Name: fcm_django_fcmdevice_registration_id_9918b353_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX fcm_django_fcmdevice_registration_id_9918b353_like ON public.fcm_django_fcmdevice USING btree (registration_id text_pattern_ops);


--
-- Name: fcm_django_fcmdevice_user_id_6cdfc0a2; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX fcm_django_fcmdevice_user_id_6cdfc0a2 ON public.fcm_django_fcmdevice USING btree (user_id);


--
-- Name: scores_reason_company_id_2e48d42d; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX scores_reason_company_id_2e48d42d ON public.scores_reason USING btree (company_id);


--
-- Name: scores_score_created_by_id_dcd4c71f; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX scores_score_created_by_id_dcd4c71f ON public.scores_score USING btree (created_by_id);


--
-- Name: scores_score_role_id_b1076389; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX scores_score_role_id_b1076389 ON public.scores_score USING btree (role_id);


--
-- Name: timesheet_departmentschedule_department_id_04e73dd2; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX timesheet_departmentschedule_department_id_04e73dd2 ON public.timesheet_departmentschedule USING btree (department_id);


--
-- Name: timesheet_employeeschedule_role_id_4238e2cb; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX timesheet_employeeschedule_role_id_4238e2cb ON public.timesheet_employeeschedule USING btree (role_id);


--
-- Name: timesheet_timesheet_role_id_6c5d8d9b; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX timesheet_timesheet_role_id_6c5d8d9b ON public.timesheet_timesheet USING btree (role_id);


--
-- Name: token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_like; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_like ON public.token_blacklist_outstandingtoken USING btree (jti varchar_pattern_ops);


--
-- Name: token_blacklist_outstandingtoken_user_id_83bc629a; Type: INDEX; Schema: public; Owner: damir
--

CREATE INDEX token_blacklist_outstandingtoken_user_id_83bc629a ON public.token_blacklist_outstandingtoken USING btree (user_id);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_otptoken auth_user_otptoken_company_id_9f5a9c29_fk_companies_company_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_otptoken
    ADD CONSTRAINT auth_user_otptoken_company_id_9f5a9c29_fk_companies_company_id FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_otptoken auth_user_otptoken_user_id_b0f35f22_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_otptoken
    ADD CONSTRAINT auth_user_otptoken_user_id_b0f35f22_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_pendinguser auth_user_pendinguse_department_id_c04ea59b_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_pendinguser
    ADD CONSTRAINT auth_user_pendinguse_department_id_c04ea59b_fk_companies FOREIGN KEY (department_id) REFERENCES public.companies_department(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_resetpasswordtoken auth_user_resetpassw_user_id_51c401c1_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_resetpasswordtoken
    ADD CONSTRAINT auth_user_resetpassw_user_id_51c401c1_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_groups auth_user_user_groups_group_id_f9a20b05_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_groups
    ADD CONSTRAINT auth_user_user_groups_group_id_f9a20b05_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_groups auth_user_user_groups_user_id_9fd2c989_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_groups
    ADD CONSTRAINT auth_user_user_groups_user_id_9fd2c989_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user auth_user_user_owner_id_eb2cf8ce_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user
    ADD CONSTRAINT auth_user_user_owner_id_eb2cf8ce_fk_auth_user_user_id FOREIGN KEY (owner_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user auth_user_user_selected_company_id_10295ecd_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user
    ADD CONSTRAINT auth_user_user_selected_company_id_10295ecd_fk_companies FOREIGN KEY (selected_company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_user_permissions auth_user_user_user__permission_id_2900c446_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_user_permissions
    ADD CONSTRAINT auth_user_user_user__permission_id_2900c446_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_user_permissions auth_user_user_user__user_id_6afc8fee_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.auth_user_user_user_permissions
    ADD CONSTRAINT auth_user_user_user__user_id_6afc8fee_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklist checklist_checklist_company_id_f6a65f4a_fk_companies_company_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklist
    ADD CONSTRAINT checklist_checklist_company_id_f6a65f4a_fk_companies_company_id FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklist checklist_checklist_department_id_d5803019_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklist
    ADD CONSTRAINT checklist_checklist_department_id_d5803019_fk_companies FOREIGN KEY (department_id) REFERENCES public.companies_department(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklistassign checklist_checklista_checklist_id_afd8f4c4_fk_checklist; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistassign
    ADD CONSTRAINT checklist_checklista_checklist_id_afd8f4c4_fk_checklist FOREIGN KEY (checklist_id) REFERENCES public.checklist_checklist(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklistassign checklist_checklistassign_user_id_793aa2d8_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistassign
    ADD CONSTRAINT checklist_checklistassign_user_id_793aa2d8_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklistcomplete checklist_checklistc_checklist_id_01a4ab98_fk_checklist; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistcomplete
    ADD CONSTRAINT checklist_checklistc_checklist_id_01a4ab98_fk_checklist FOREIGN KEY (checklist_id) REFERENCES public.checklist_checklist(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklistcomplete checklist_checklistc_user_id_afe4b9fb_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistcomplete
    ADD CONSTRAINT checklist_checklistc_user_id_afe4b9fb_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_checklistschedule checklist_checklists_checklist_id_f00ec341_fk_checklist; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_checklistschedule
    ADD CONSTRAINT checklist_checklists_checklist_id_f00ec341_fk_checklist FOREIGN KEY (checklist_id) REFERENCES public.checklist_checklist(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_file checklist_file_uploaded_by_id_37f0f59e_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_file
    ADD CONSTRAINT checklist_file_uploaded_by_id_37f0f59e_fk_auth_user_user_id FOREIGN KEY (uploaded_by_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_task checklist_task_group_id_f10a2db5_fk_checklist_taskgroup_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_task
    ADD CONSTRAINT checklist_task_group_id_f10a2db5_fk_checklist_taskgroup_id FOREIGN KEY (group_id) REFERENCES public.checklist_taskgroup(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_taskcheck checklist_taskcheck_task_id_99307548_fk_checklist_task_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskcheck
    ADD CONSTRAINT checklist_taskcheck_task_id_99307548_fk_checklist_task_id FOREIGN KEY (task_id) REFERENCES public.checklist_task(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_taskcheck checklist_taskcheck_user_id_9cda16eb_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskcheck
    ADD CONSTRAINT checklist_taskcheck_user_id_9cda16eb_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_taskfile checklist_taskfile_file_id_5f0f1972_fk_checklist_file_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskfile
    ADD CONSTRAINT checklist_taskfile_file_id_5f0f1972_fk_checklist_file_id FOREIGN KEY (file_id) REFERENCES public.checklist_file(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_taskfile checklist_taskfile_task_id_809b677b_fk_checklist_task_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskfile
    ADD CONSTRAINT checklist_taskfile_task_id_809b677b_fk_checklist_task_id FOREIGN KEY (task_id) REFERENCES public.checklist_task(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: checklist_taskgroup checklist_taskgroup_checklist_id_d7155899_fk_checklist; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.checklist_taskgroup
    ADD CONSTRAINT checklist_taskgroup_checklist_id_d7155899_fk_checklist FOREIGN KEY (checklist_id) REFERENCES public.checklist_checklist(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_company companies_company_owner_id_89314e2a_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_company
    ADD CONSTRAINT companies_company_owner_id_89314e2a_fk_auth_user_user_id FOREIGN KEY (owner_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_department companies_department_company_id_fd75b821_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department
    ADD CONSTRAINT companies_department_company_id_fd75b821_fk_companies FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_department_zones companies_department_department_id_e966ba85_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department_zones
    ADD CONSTRAINT companies_department_department_id_e966ba85_fk_companies FOREIGN KEY (department_id) REFERENCES public.companies_department(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_department companies_department_head_of_department_i_d3999b0a_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department
    ADD CONSTRAINT companies_department_head_of_department_i_d3999b0a_fk_companies FOREIGN KEY (head_of_department_id) REFERENCES public.companies_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_department_zones companies_department_zone_id_d04dea90_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_department_zones
    ADD CONSTRAINT companies_department_zone_id_d04dea90_fk_companies FOREIGN KEY (zone_id) REFERENCES public.companies_zone(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_role companies_role_company_id_c4cb615b_fk_companies_company_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role
    ADD CONSTRAINT companies_role_company_id_c4cb615b_fk_companies_company_id FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_role companies_role_department_id_4b4f2515_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role
    ADD CONSTRAINT companies_role_department_id_4b4f2515_fk_companies FOREIGN KEY (department_id) REFERENCES public.companies_department(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_role companies_role_user_id_d6be1a2d_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_role
    ADD CONSTRAINT companies_role_user_id_d6be1a2d_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_zone companies_zone_company_id_c9498d65_fk_companies_company_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone
    ADD CONSTRAINT companies_zone_company_id_c9498d65_fk_companies_company_id FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_zone_employees companies_zone_employees_role_id_5b6d4258_fk_companies_role_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone_employees
    ADD CONSTRAINT companies_zone_employees_role_id_5b6d4258_fk_companies_role_id FOREIGN KEY (role_id) REFERENCES public.companies_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: companies_zone_employees companies_zone_employees_zone_id_7a22a12a_fk_companies_zone_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.companies_zone_employees
    ADD CONSTRAINT companies_zone_employees_zone_id_7a22a12a_fk_companies_zone_id FOREIGN KEY (zone_id) REFERENCES public.companies_zone(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_clocked_id_47a69f82_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_clocked_id_47a69f82_fk_django_ce FOREIGN KEY (clocked_id) REFERENCES public.django_celery_beat_clockedschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_crontab_id_d3cba168_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_crontab_id_d3cba168_fk_django_ce FOREIGN KEY (crontab_id) REFERENCES public.django_celery_beat_crontabschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_interval_id_a8ca27da_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_interval_id_a8ca27da_fk_django_ce FOREIGN KEY (interval_id) REFERENCES public.django_celery_beat_intervalschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_solar_id_a87ce72c_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_solar_id_a87ce72c_fk_django_ce FOREIGN KEY (solar_id) REFERENCES public.django_celery_beat_solarschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: fcm_django_fcmdevice fcm_django_fcmdevice_user_id_6cdfc0a2_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.fcm_django_fcmdevice
    ADD CONSTRAINT fcm_django_fcmdevice_user_id_6cdfc0a2_fk_auth_user_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: scores_reason scores_reason_company_id_2e48d42d_fk_companies_company_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_reason
    ADD CONSTRAINT scores_reason_company_id_2e48d42d_fk_companies_company_id FOREIGN KEY (company_id) REFERENCES public.companies_company(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: scores_score scores_score_created_by_id_dcd4c71f_fk_auth_user_user_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_score
    ADD CONSTRAINT scores_score_created_by_id_dcd4c71f_fk_auth_user_user_id FOREIGN KEY (created_by_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: scores_score scores_score_role_id_b1076389_fk_companies_role_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.scores_score
    ADD CONSTRAINT scores_score_role_id_b1076389_fk_companies_role_id FOREIGN KEY (role_id) REFERENCES public.companies_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: timesheet_departmentschedule timesheet_department_department_id_04e73dd2_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_departmentschedule
    ADD CONSTRAINT timesheet_department_department_id_04e73dd2_fk_companies FOREIGN KEY (department_id) REFERENCES public.companies_department(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: timesheet_employeeschedule timesheet_employeesc_role_id_4238e2cb_fk_companies; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_employeeschedule
    ADD CONSTRAINT timesheet_employeesc_role_id_4238e2cb_fk_companies FOREIGN KEY (role_id) REFERENCES public.companies_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: timesheet_timesheet timesheet_timesheet_role_id_6c5d8d9b_fk_companies_role_id; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.timesheet_timesheet
    ADD CONSTRAINT timesheet_timesheet_role_id_6c5d8d9b_fk_companies_role_id FOREIGN KEY (role_id) REFERENCES public.companies_role(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: token_blacklist_blacklistedtoken token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_blacklistedtoken
    ADD CONSTRAINT token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk FOREIGN KEY (token_id) REFERENCES public.token_blacklist_outstandingtoken(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: token_blacklist_outstandingtoken token_blacklist_outs_user_id_83bc629a_fk_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: damir
--

ALTER TABLE ONLY public.token_blacklist_outstandingtoken
    ADD CONSTRAINT token_blacklist_outs_user_id_83bc629a_fk_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_user_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

