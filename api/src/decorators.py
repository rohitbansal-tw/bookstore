import functools
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def log(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        args_repr = [repr(a) for a in args]
        kwargs_repr = [f"{k}={v!r}" for k, v in kwargs.items()]
        signature = ", ".join(args_repr + kwargs_repr)
        logger.debug("function {} called with args {}".format(func.__name__, signature))
        try:
            result = func(*args, **kwargs)
            return result
        except Exception as e:
            logger.exception("Exception raised in {}. exception: {}".format(func.__name__, str(e)))
            raise e
    return wrapper
